import { Injectable, Input } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable, Subscription } from 'rxjs';

import { AuthorizationService } from './authorization.service';

@Injectable({
  providedIn: 'root'
})
export class RequireAuthenticationGuard implements CanActivate {

  constructor(
    private router: Router,
    private authorizationService: AuthorizationService) {
      this.subscription = this.authorizationService.isLoggedIn$.subscribe(
        loggedIn => {
          this.isLoggedIn = loggedIn;
      });
    }

  @Input() isLoggedIn: boolean;
  subscription: Subscription

  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {

    if (this.isLoggedIn) {
      return true;
    } else {
      // not logged in so redirect to login page with the return url
      this.router.navigate(['/login'], { queryParams: { returnUrl: state.url }});
      return false;
    }
  }
  
}
