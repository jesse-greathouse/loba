import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Server } from './server';

@Injectable({
  providedIn: 'root'
})
export class ServerService extends BaseService {

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('server', http, messageService);
  }

  getServers(): Observable<Server[]> {
    return this.getAll();
  }

  /** GET server by id. Will 404 if id not found */
  getServer(id: number): Observable<Server> {
    return this.get(id);
  }

  /** PUT: update the server */
  updateServer(server: Server): Observable<any> {
    return this.update(server);
  }

  /** POST: add a new server */
  addServer(server: Server): Observable<Server> {
    return this.add(server);
  }

  /** DELETE: delete the server from the server */
  deleteServer(server: Server | number): Observable<Server> {
    return this.delete(server);
  }
}
