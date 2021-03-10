import { Injectable, Input } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable, Subscription } from 'rxjs';

import { AuthorizationService } from './authorization.service';

@Injectable({
  providedIn: 'root'
})
export class RequireAdminGuard implements CanActivate {

  constructor(private authorizationService: AuthorizationService) {}

  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {

    if (this.authorizationService.ss.isAdmin) {
      return true;
    } else {
      return false;
    }
  }
  
}
