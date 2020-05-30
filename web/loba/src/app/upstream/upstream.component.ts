import { Component, OnInit, OnChanges, Input } from '@angular/core';
import { Observable } from 'rxjs';
import { FormControl, FormGroupDirective, NgForm, Validators } from '@angular/forms';
import { ErrorStateMatcher } from '@angular/material/core';

import { Site } from '../site';
import { Method } from '../method';
import { Upstream } from '../upstream';
import { MethodService } from '../method.service';
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

  @Input() site: Site;
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
    private isLoadingService: IsLoadingService) { }

  ngOnInit(): void {
    this.getUpstream();
  }

  ngOnChanges(): void {
    this.getUpstream();
  }

  focusOut(): void {
    this.site.upstream.hash = this.hashFormControl.value;
    this.save();
  }

  updateHashFormControl() {
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

  private fetchMethod(id: number): Observable<Method> {
    return this.methodService.getMethod(id);
  }

  private factoryNewUpstream(method: Method): Upstream {
    return {
      id: 0,
      site: this.site,
      servers: [],
      method: method,
      hash: null,
      consistent: false
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
          this.isLoadingService.remove();
        });
    } else {
      this.isLoadingService.add();
      this.fetchMethod(1)
        .subscribe(method => {
          this.site.upstream = this.factoryNewUpstream(method);
          this.updateHashFormControl();
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
      this.upstreamService.addUpstream(this.site.upstream)
        .subscribe(upstream => {
          this.site.upstream = upstream;
          this.isLoadingService.remove();
        });
    } else {
      this.upstreamService.updateUpstream(this.site.upstream)
        .subscribe(upstream => {
          this.site.upstream = upstream;
          this.isLoadingService.remove();
        });
    }
  }
}
