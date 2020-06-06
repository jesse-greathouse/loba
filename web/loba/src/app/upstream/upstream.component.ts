import { Component, ViewChildren, QueryList, OnInit, OnChanges, Input } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { FormControl, FormGroupDirective, NgForm, Validators } from '@angular/forms';
import { ErrorStateMatcher } from '@angular/material/core';

import { Site } from '../site';
import { Method } from '../method';
import { Server } from '../server';
import { Upstream } from '../upstream';
import { ServerComponent } from '../server/server.component';
import { MethodService } from '../method.service';
import { ServerService } from '../server.service';
import { UpstreamService } from '../upstream.service';
import { IsLoadingService } from '../is-loading.service';

/** Error when invalid control is dirty, touched, or submitted. */
export class HashErrorStateMatcher implements ErrorStateMatcher {
  isErrorState(control: FormControl | null, form: FormGroupDirective | NgForm | null): boolean {
    const isSubmitted = form && form.submitted;
    return !!(control && control.invalid && (control.dirty || control.touched || isSubmitted));
  }
}

@Component({
  selector: 'app-upstream',
  templateUrl: './upstream.component.html',
  styleUrls: ['./upstream.component.css']
})
export class UpstreamComponent implements OnInit, OnChanges {

  @ViewChildren(ServerComponent)
  private servers: QueryList<ServerComponent>;

  @Input() site: Site;
  @Input() lockHealth: boolean = false;
  @Input() fail_timeout: number = null;
  @Input() max_fails: number = null;
  hashMatcher = new HashErrorStateMatcher();
  hashFormControl = new FormControl({
    value: '',
    disabled: true
  }, [
    Validators.required
  ]);

  constructor(
    private upstreamService: UpstreamService,
    private methodService: MethodService,
    private serverService: ServerService,
    private isLoadingService: IsLoadingService) { }

  ngOnInit(): void {
    this.getUpstream();
  }

  ngOnChanges(): void {
    this.getUpstream();
  }

  isSslReady(): boolean {
    if (this.site.upstream.certificate == null ) return false;
    if (this.site.upstream.certificate.certificate == null) return false;
    if (this.site.upstream.certificate.key == null) return false;
    return true;
  }

  focusOut(): void {
    this.site.upstream.hash = this.hashFormControl.value;
    this.save();
  }

  updateHashFormControl(): void {
    if (this.site.upstream !== null) {
      if (this.site.upstream.method.id === 4) {
        this.hashFormControl.setValue(this.site.upstream.hash);
        this.hashFormControl.enable();
        this.hashFormControl.markAsTouched();
      } else {
        this.hashFormControl.setValue(null);
        this.site.upstream.consistent = false;
        this.hashFormControl.disable();
      }
    }
  }

  serverFocusOut(): void {
    if (this.site.upstream === null) return;

    if (this.lockHealth) {
      this.propogateLockedHealth();
      for (let server of this.servers) {
        server.save();
      }
    }
  }

  changeMethod(id: number): void  {
    this.fetchMethod(id)
      .subscribe(method => {
        this.site.upstream.method = method;
        this.updateHashFormControl();
        this.save();
      });
  }

  getUpstream(): void {
    if (this.site.upstream !== null) {
      this.isLoadingService.add();
      this.upstreamService.getUpstream(this.site.upstream.id)
        .subscribe(upstream => {
          this.site.upstream = upstream;
          this.updateHashFormControl();
          this.checkHealthLocked();
          this.isLoadingService.remove();
        });
    } else {
      this.isLoadingService.add();
      this.fetchMethod(1)
        .subscribe(method => {
          this.site.upstream = this.factoryNewUpstream(method);
          this.updateHashFormControl();
          this.checkHealthLocked();
          this.isLoadingService.remove();
        });
    }
  }

  addServer(host: string): void {
    // There can be a situation where the upstream has not been saved
    // In this case save the new upstream and call addServer
    if (!this.site.upstream.id) {
      this.addNew()
        .subscribe(upstream => {
          this.addServer(host);
        });
    } else {
      this.isLoadingService.add();
      let server = this.factoryNewServer(host, this.fail_timeout, this.max_fails);
      this.serverService.addServer(server)
        .subscribe(server => {
          this.getUpstream();
          this.isLoadingService.remove();
        });
    }
  }

  save(): void {
    if (this.hashFormControl.enabled && this.hashFormControl.invalid) {
      return;
    }
    this.isLoadingService.add();

    // If the upstream is null
    // then it's new and it should be posted.
    if (!this.site.upstream.id) {
      this.addNew()
        .subscribe(upstream => {
          this.isLoadingService.remove();
        })
    } else {
      this.upstreamService.updateUpstream(this.site.upstream)
        .subscribe(upstream => {
          this.site.upstream = upstream;
          this.isLoadingService.remove();
        });
    }
  }

  // Creates a new Upstream 
  // when the active upstream has not been saved before
  private addNew(): Observable<Upstream> {
    return this.upstreamService.addUpstream(this.site.upstream).pipe(
      map(upstream => {
        this.site.upstream = upstream;
        return upstream;
      })
    );
  }

  private fetchMethod(id: number): Observable<Method> {
    return this.methodService.getMethod(id);
  }

  private checkHealthLocked(): void {
    if (this.site.upstream === null) return;

    const serverlen = this.site.upstream.servers.length;
    let locked = true;
    let server: Server;
    let firstServer: Server;

    // If there is one or less servers configured
    // treat it as locked by default
    if (serverlen < 2)  {
      // If there is one server configured
      // Set the fail_timeout and max_fails to match
      if (serverlen === 1) {
        server = this.site.upstream.servers[0];
        this.fail_timeout = server.fail_timeout;
        this.max_fails = server.max_fails;
      }
      this.lockHealth = locked;
      return;
    }

    // If there 2 or more servers
    // Signal them as locked if they have the same values
    for (let i = 0; i < serverlen; i++) {
      server = this.site.upstream.servers[i];

      if (i === 0) {
        firstServer = server;
        continue;
      }

      if ((server.fail_timeout !== firstServer.fail_timeout)
         || (server.max_fails !== firstServer.max_fails)) {
          locked = false;
          break;
      }
    }

    if (locked) {
      this.fail_timeout = firstServer.fail_timeout;
      this.max_fails = firstServer.max_fails;
    }

    this.lockHealth = locked;
  }

  private propogateLockedHealth(): void {
    this.site.upstream.servers.forEach(server => {
      server.max_fails = this.max_fails;
      server.fail_timeout = this.fail_timeout;
    });
  }

  private factoryNewUpstream(method: Method): Upstream {
    return {
      id: 0,
      site: this.site,
      servers: [],
      method: method,
      hash: null,
      consistent: false,
      ssl: false,
      certificate: null,
    }
  }

  private factoryNewServer(host: string, fail_timeout: number = null, max_fails: number = null): Server {
    return {
      id: 0,
      host: host,
      backup: 0,
      upstream_id: this.site.upstream.id,
      weight: null,
      fail_timeout: fail_timeout,
      max_fails: max_fails
    }
  }
}
