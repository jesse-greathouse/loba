import { Injectable } from '@angular/core';
import {
  HttpEvent, HttpInterceptor, HttpHandler, HttpRequest
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class TransformerInterceptor implements HttpInterceptor {

  intercept(req: HttpRequest<any>, next: HttpHandler):
    Observable<HttpEvent<any>> {

      // Only transform the request body on POST or PUT
      if (req.method == "POST" || req.method == "PUT") {

        // dont mess with the req.body if its a FormData type
        if (!(req.body instanceof FormData)) {

          // Don't modify the request directly
          // instead, make a copy
          const newBody = { ...req.body };

          // Distribute transform based on request url
          if (/^api\/site/.test(req.url)) {
            this.transformSite(newBody);
          } else if (/^api\/upstream/.test(req.url)) {
            this.transformUpstream(newBody);
          } else if (/^api\/server/.test(req.url)) {
            this.transformServer(newBody);
          }

          // return a clone of the request with the transformed body
          const newReq = req.clone({ body: newBody });
          return next.handle(newReq);
        }
      }

      return next.handle(req);
  }

  transformSite(body: any): void {
    body.active = (body.active) ? 1 : 0;

    // remove unused input from the request
    delete body.upstream;
  }

  transformServer(body: any): void {
    body.backup = (body.backup) ? 1 : 0;

    // remove unused input from the request
    if (!body.id) delete(body.id);
    delete body.upstream;
  }

  transformUpstream(body: any): void {
    body.method_id = body.method.id;
    body.site_id = body.site.id;
    body.consistent = (body.consistent) ? 1 : 0;
    body.ssl = (body.ssl) ? 1 : 0;

    // remove unused input from the request
    if (!body.id) delete(body.id);
    delete body.method;
    delete body.site;
    delete body.servers;
  }
}