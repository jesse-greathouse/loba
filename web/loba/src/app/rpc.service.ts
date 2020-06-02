import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { Transformable } from './transformable';
import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Rpc } from './rpc';

@Injectable({
  providedIn: 'root'
})
export class RpcService extends BaseService implements Transformable {

  protected apiUrl: string;

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('rpc', http, messageService);
      this.apiUrl = this.resourceName;
  }

  composeSites() : Observable<Rpc> {
    const url = `${this.apiUrl}/compose-sites`;
    return this.http.get<Rpc>(url).pipe(
      tap(_ => this.log(`executed RPC: composeSites`, false)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handleError<Rpc>(`composeSites`))
    );
  }

  reloadNginx() : Observable<Rpc> {
    const url = `${this.apiUrl}/reload-nginx`;
    return this.http.get<Rpc>(url).pipe(
      tap(_ => this.log(`executed RPC: reloadNginx`, false)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handleError<Rpc>(`reloadNginx`))
    );
  }

  testNginx() : Observable<Rpc> {
    const url = `${this.apiUrl}/test-nginx`;
    return this.http.get<Rpc>(url).pipe(
      tap(_ => this.log(`executed RPC: testNginx`, false)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handleError<Rpc>(`testNginx`))
    );
  }

  transform(data: any): any {
    return super.transform(data);
  }
}
