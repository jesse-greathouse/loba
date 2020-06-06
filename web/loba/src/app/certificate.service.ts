import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Certificate } from './certificate';

@Injectable({
  providedIn: 'root'
})
export class CertificateService extends BaseService {

  uploadOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'multipart/form-data' }),
    reportProgress: true
  };

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

  /** PUT: update the certificate */
  updateCertificate( id: number, formData: FormData): Observable<Certificate> {
    const url = `${this.apiUrl}/${id}`;
    return this.http.put(url, formData, this.uploadOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`update${this.capResourceName}`))
    );
  }

  /** POST: add a new certificate */
  addCertificate(formData: FormData): Observable<Certificate> {
    formData.forEach((val, key) => {
      console.log(`${key}: ${val}`);
    });
    return this.http.post<any>(this.apiUrl, formData, this.uploadOptions).pipe(
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
