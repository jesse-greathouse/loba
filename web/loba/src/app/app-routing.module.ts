import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { LoginComponent }  from './login/login.component';
import { SiteDetailComponent }  from './site-detail/site-detail.component';
import { RequireAuthenticationGuard }  from './require-authentication.guard'

const routes: Routes = [
  {
    path: '',
    component: SiteDetailComponent,
    canActivate: [ RequireAuthenticationGuard ],
  },
  {
    path: 'site/:domain',
    component: SiteDetailComponent,
    canActivate: [ RequireAuthenticationGuard ],
  },
  { path: 'login', component: LoginComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
