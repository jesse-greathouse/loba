import { Injectable } from '@angular/core';
import { HttpClient} from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Certificate } from './certificate';
import { Upstream } from './upstream';

@Injectable({
  providedIn: 'root'
})
export class CertificateService extends BaseService {

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('certificate', http, messageService);
  }

  getCertificates(): Observable<Certificate[]> {
    return this.getAll();
  }

  /** GET certificate by id. Will 404 if id not found */
  getCertificate(id: number): Observable<Certificate> {
    return this.get(id);
  }

  /** GET object by upstream. Will return null if not found */
  getCertificateByUpstream(upstream: Upstream): Observable<any> {
    const url = `${this.apiUrl}/upstream/${upstream.id}`;
    return this.http.get<any>(url).pipe(
      tap(_ => this.log(`fetched ${this.resourceName} upstream_id: ${upstream.id}`)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handle404AbleError<any>(`get${this.capResourceName}: ${upstream.id}`))
    );
  }

  /** PUT: update the certificate */
  updateCertificate( id: number, formData: FormData): Observable<Certificate> {
    const url = `${this.apiUrl}/${id}`;
    return this.http.put(url, formData).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`update${this.capResourceName}`))
    );
  }

  removeCertificate(certificate: Certificate): Observable<Certificate> {
    const url = `${this.apiUrl}/remove/certificate/${certificate.id}`;
    return this.http.get(url, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`update${this.capResourceName}`))
    );
  }

  removeKey(certificate: Certificate): Observable<Certificate> {
    const url = `${this.apiUrl}/remove/key/${certificate.id}`;
    return this.http.get(url, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`update${this.capResourceName}`))
    );
  }

  /** POST: add a new certificate */
  addCertificate(formData: FormData): Observable<Certificate> {
    return this.http.post<any>(this.apiUrl, formData).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`add${this.capResourceName}`))
    );
  }

  /** DELETE: delete the certificate from the server */
  deleteCertificate(certificate: Certificate | number): Observable<Certificate> {
    return this.delete(certificate);
  }
}
