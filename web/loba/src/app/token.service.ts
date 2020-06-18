import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, Subject } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { AppConfig } from './app.config';
import { Token } from './token';
import { Transformable } from './transformable';
import { BaseService } from './base.service';
import { MessageService } from './message.service';

@Injectable({
  providedIn: 'root'
})
export class TokenService extends BaseService implements Transformable {

  constructor(
    protected appConfig: AppConfig,
    protected http: HttpClient,
    protected messageService: MessageService) {
      super('token', http, messageService);
  }

  // Many component may require the session token
  // Save it here so other services/components can subscribe to it
  private sessionToken:Subject<Token> = new Subject<Token>();

  sessionToken$ = this.sessionToken.asObservable();

  /** POST: login with a username and password */
  login(email: string, password: string): Observable<Token> {
    const ob = {"email": email, "password": password};
    return this.http.post<any>(`/api/login`, ob, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`login`))
    );
  }

  /** GET: logout */
  logout(): Observable<Token> {
    return this.http.get<any>(`/api/logout`, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        this.destorySessionToken();
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`logout`))
    );
  }

  /** GET the Token assigned to the session. Will 404 if id not found */
  fetchSessionToken(): void {
    this.sessionToken.next(this.getSessionToken());

    const url = `${this.apiUrl}/token/${this.appConfig.token}`;
    this.http.get<Token>(url).pipe(
      tap(_ => this.log(`fetched token: ${this.appConfig.token}`, false)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handleError<Token>(`getSessionToken: ${this.appConfig.token}`))
    ).subscribe((token: Token)  => {
      this.storeSessionToken(token);
      this.sessionToken.next(token);
    });
  }

  private getSessionToken(): any {
    const tokenStr = localStorage.getItem(this.appConfig.token);
    if (!tokenStr) return tokenStr;
    return JSON.parse(tokenStr);
  }

  private storeSessionToken(token: Token): void {
    localStorage.setItem(this.appConfig.token, JSON.stringify(token));
  }

  private destorySessionToken(): void {
    localStorage.removeItem(this.appConfig.token)
  }

  transform(data: any): any {
    data = super.transform(data);
    delete data.user_id;
    return data;
  }
}
