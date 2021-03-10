import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { User } from './user';

@Injectable({
  providedIn: 'root'
})
export class UserService extends BaseService {

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('user', http, messageService);
  }

  getUsers(): Observable<User[]> {
    return this.getAll();
  }

  /** GET user by id. Will 404 if id not found */
  getUserByEmail(email: string): Observable<User> {
    const url = `${this.apiUrl}?email=${email}`;
    return this.http.get<User>(url).pipe(
      tap(_ => this.log(`fetched user with email: ${email}`, false)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<User>(`getUserByEmail: ${email}`))
    );
  }

  /** GET user by id. Will 404 if id not found */
  getUser(id: number): Observable<User> {
    return this.get(id);
  }

  /** PUT: update the user */
  updateUser(user: User): Observable<any> {
    return this.update(user);
  }

  /** POST: add a new user */
  addUser(user: User): Observable<User> {
    return this.add(user);
  }

  /** DELETE: delete the user from the user */
  deleteUser(user: User | number): Observable<User> {
    return this.delete(user);
  }

  transform(data: any) {
    data = super.transform(data);
    data.first_name = (data.first_name) ? data.first_name : '';
    data.last_name = (data.last_name) ? data.last_name : '';
    return data;
  }
}