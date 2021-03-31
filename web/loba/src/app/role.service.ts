import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { User } from './user';
import { Role } from './role';

@Injectable({
    providedIn: 'root'
  })
  export class RoleService extends BaseService {
    constructor(
        protected http: HttpClient,
        protected messageService: MessageService) { 
          super('role', http, messageService);
      }

    assignRole(user: User, role: Role): Observable<any> {
        const pld = { user_id: user.id, role_id: role.id };
        const url = `${this.apiUrl}/assign`;
        return this.http.post<any>(url, pld, this.httpOptions).pipe(
            map((resp: any) => {
              this.log(resp.meta.message, 'success');
              return this.transform(resp.data);
            }),
            catchError(this.handleError<any>(`assign role: ${role.name} to ${user.email}`))
          );
    }

    removeRole(user: User, role: Role): Observable<any> {
        const pld = { user_id: user.id, role_id: role.id };
        const url = `${this.apiUrl}/remove`;
        return this.http.post<any>(url, pld, this.httpOptions).pipe(
            map((resp: any) => {
              this.log(resp.meta.message, 'success');
              return this.transform(resp.data);
            }),
            catchError(this.handleError<any>(`remove role: ${role.name} from ${user.email}`))
          );
    }
  }