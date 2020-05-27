import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Method } from './method';

@Injectable({
  providedIn: 'root'
})
export class MethodService extends BaseService {

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('method', http, messageService);
  }

  getMethods(): Observable<Method[]> {
    return this.getAll();
  }

  /** GET method by id. Will 404 if id not found */
  getMethod(id: number): Observable<Method> {
    return this.get(id);
  }
}
