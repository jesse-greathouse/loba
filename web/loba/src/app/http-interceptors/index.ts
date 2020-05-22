import { HTTP_INTERCEPTORS } from '@angular/common/http';

import { TransformerInterceptor } from './transformer-interceptor';

/** Http interceptor providers in outside-in order */
export const HttpInterceptorProviders = [
  { provide: HTTP_INTERCEPTORS, useClass: TransformerInterceptor, multi: true },
];