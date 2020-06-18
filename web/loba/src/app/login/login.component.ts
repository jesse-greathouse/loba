import { Component, OnInit, Input, OnDestroy } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Subscription } from 'rxjs';

import { TokenService } from '../token.service';
import { IsLoadingService } from '../is-loading.service';
import { IsLoggedInService } from '../is-logged-in.service';

const ENTER_KEY = 13;

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit, OnDestroy {

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private tokenService: TokenService,
    private isLoadingService: IsLoadingService,
    private isLoggedInService: IsLoggedInService) {
      this.isLoadingSubscription = this.isLoadingService.isLoading$()
        .subscribe(isLoading => {
            this.isLoading = isLoading;
        });

      this.loggedInsubscription = this.isLoggedInService.isLoggedIn$
        .subscribe(() => {
          let returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/';
          this.router.navigateByUrl(returnUrl);
          this.isLoadingService.remove();
        });
    }
  
  @Input() email: string;
  @Input() password: string;
  @Input() isLoading: boolean;
  loggedInsubscription: Subscription
  isLoadingSubscription: Subscription;
  hide: boolean = true;

  ngOnInit(): void {
  }

  login(): void {
    this.isLoadingService.add();
    this.tokenService.login(this.email, this.password)
    .subscribe(() => {
      this.isLoggedInService.fetchToken();
    });
  }

  loginKeyDown(event: any): void {
    if (event.keyCode === ENTER_KEY) {
      this.login()
    }
  }

  ngOnDestroy(): void {
    this.loggedInsubscription.unsubscribe();
  }

}
