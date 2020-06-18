import { Injectable, Input } from '@angular/core';
import { Subject, Subscription }    from 'rxjs';

import { Token } from  './token';
import { TokenService } from './token.service';

@Injectable({
  providedIn: 'root'
})
export class IsLoggedInService {

  constructor(
    private tokenService: TokenService) {
      this.sessionTokenSubscription = this.tokenService.sessionToken$
        .subscribe((sessionToken) => {
          if (sessionToken) {
            if (sessionToken.user !== null) {
              this.loggedIn.next(true);
            } else {
              this.loggedIn.next(false);
            }
          } else {
            this.loggedIn.next(false);
          }
        });
  }

  private loggedIn:Subject<boolean> = new Subject<boolean>();
  @Input() sessionToken: Token;
  sessionTokenSubscription: Subscription
  isLoggedIn$ = this.loggedIn.asObservable();

  fetchToken() {
    this.tokenService.fetchSessionToken();
  }

  logout() {
    this.loggedIn.next(false);
  }
}
