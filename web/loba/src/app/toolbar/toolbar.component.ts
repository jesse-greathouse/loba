import { Component, OnInit, Input, OnDestroy } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Subscription } from 'rxjs';

import { Rpc } from  '../rpc';
import { TokenService } from '../token.service';
import { RpcService } from '../rpc.service';
import { IsLoadingService } from '../is-loading.service';
import { IsLoggedInService } from '../is-logged-in.service';
import { MessageService } from '../message.service';

interface TestResult {
  file: string,
  syntax: boolean,
  success: boolean,
  error: string,
}

@Component({
  selector: 'app-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit, OnDestroy {

  constructor(
    private tokenService: TokenService,
    private rpcService: RpcService,
    private messageService: MessageService,
    private isLoadingService: IsLoadingService,
    private isLoggedInService: IsLoggedInService,
    private route: ActivatedRoute,
    private router: Router ) {
      this.loggedInsubscription = this.isLoggedInService.isLoggedIn$.subscribe(
        loggedIn => {
          this.isLoggedIn = loggedIn;
      });
  }

  @Input() isLoggedIn: boolean;
  loggedInsubscription: Subscription

  ngOnInit(): void {
  }

  goHome() : void {
    this.router.navigate([''], { relativeTo: this.route });
  }

  goLogin() : void {
    this.router.navigate(['login'], { relativeTo: this.route });
  }

  goLogout(): void {
    this.isLoadingService.add();
    this.tokenService.logout()
      .subscribe(() => {
        this.isLoggedInService.logout();
        this.isLoadingService.remove();
        location.reload();
      });
  }

  commit() : void {
    this.isLoadingService.add();

    this.rpcService.composeSites()
      .subscribe((rpc: Rpc) => {
        if (!rpc.ok) {
          this.messageService.add(`compose-sites failed: ${rpc.stderr}`, 'danger');
          this.isLoadingService.remove();
          return;
        }
        this.isLoadingService.remove();
        this.reload();
      });
  }

  test() : void {
    this.isLoadingService.add();

    this.rpcService.testNginx()
      .subscribe((rpc: Rpc) => {
        const res: TestResult = this.parseTestResult(rpc);
        if (!res.success || !res.syntax) {
          const syntax: string = (res.syntax) ? 'Syntax is ok. ' : res.error;
          this.messageService.add(`Testing nginx config failed. ${syntax}`, 'danger');
        }
        this.isLoadingService.remove();
      });
  }

  reload() : void {
    this.isLoadingService.add();

    this.rpcService.reloadNginx()
      .subscribe((rpc: Rpc) => {
        if (!rpc.ok) {
          this.messageService.add(`Reloading nginx failed: ${rpc.stderr}`, 'danger');
        } else {
          this.messageService.add(`Reloaded Nginx`, 'info');
        }
        this.isLoadingService.remove();
      });
  }

  ngOnDestroy(): void {
    this.loggedInsubscription.unsubscribe();
  }

  private parseTestResult(rpc: Rpc) : TestResult {
    const subject = rpc.stderr;
    const xpFile = new RegExp('nginx: configuration file (.*) test');
    const xpSyntax = new RegExp('syntax is ok');
    const xpSuccess = new RegExp('test is successful');
    const xpError = new RegExp('nginx: \\[emerg\\] (.*)\\\nnginx');
    const mError = xpError.exec(subject);
    const mFile = xpFile.exec(subject);
    const error = (mError && mError.length > 0) ? mError[1] : '';
    const file = (mFile && mFile.length > 0) ? mFile[1] : ''

    return {
      error: error,
      file: file,
      syntax: xpSyntax.test(subject),
      success: xpSuccess.test(subject)
    };
  }

}
