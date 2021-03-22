import { Injectable, Input } from '@angular/core';
import { Subject, Subscription }    from 'rxjs';

import { Token } from  './token';
import { TokenService } from './token.service';

const ADMIN = "ADMIN";
const SUPER_USER = "SUPER_USER";

class AuthSnapshot {
  isAdmin: boolean = false;
  isSuperUser: boolean = false;
  isLoggedIn: boolean = false;
}

@Injectable({
  providedIn: 'root'
})
export class AuthorizationService {

  constructor(
    private tokenService: TokenService) {
      this.sessionTokenSubscription = this.tokenService.sessionToken$
        .subscribe((sessionToken) => {
          this.doAuthorization(sessionToken);
        });
  }

  private snapshot: AuthSnapshot = new AuthSnapshot();
  private loggedIn:Subject<boolean> = new Subject<boolean>();
  private superUser:Subject<boolean> = new Subject<boolean>();
  private admin:Subject<boolean> = new Subject<boolean>();
  @Input() sessionToken: Token;
  sessionTokenSubscription: Subscription
  isLoggedIn$ = this.loggedIn.asObservable();
  isSuperUser$ = this.superUser.asObservable();
  isAdmin$ = this.admin.asObservable();

  get ss(): AuthSnapshot {
    return this.snapshot;
  }

  fetchToken() {
    this.tokenService.fetchSessionToken();
  }

  logout() {
    this.ss.isAdmin = false;
    this.ss.isSuperUser = false;
    this.ss.isLoggedIn = false;

    this.broadcastSnapshot();
  }

  private broadcastSnapshot(): void {
    this.admin.next(this.ss.isAdmin);
    this.superUser.next(this.ss.isSuperUser);
    this.loggedIn.next(this.ss.isLoggedIn);
  }

  private doAuthorization(token: Token): void
  {
    // If no token was passed, user is not authorized
    if (token) {
      // If token is attached to a user then the user is authorized
      if (token.user !== null && token.user !== undefined) {
        this.ss.isLoggedIn = true;
        const roles = token.user.roles

        // Check for Admin role
        if (this.hasAdminRole(roles)) {
          this.ss.isAdmin = true;
          this.ss.isSuperUser = true;

        // Check for Superuser Role
        } else if (this.hasSuperUserRole(roles)) {
          this.ss.isAdmin = false;
          this.ss.isSuperUser = true;

        // Default to false for Admin and Superuser
        } else {
          this.ss.isAdmin = false;
          this.ss.isSuperUser = false;
        }
      } else {
        this.ss.isLoggedIn = false;
      }
    } else {
      this.ss.isLoggedIn = false;
    }

    this.broadcastSnapshot();
  }

  private hasAdminRole(roles: string[]) {
    for (let role of roles) {
      if (role === ADMIN) return true;
    }
    return false;
  } 

  private hasSuperUserRole(roles: string[]) {
    for (let role of roles) {
      if (role === SUPER_USER) return true;
    }
    return false;
  }
}
