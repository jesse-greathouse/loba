import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { LoginComponent }  from './login/login.component';
import { UserAdminComponent }  from './user-admin/user-admin.component';
import { SiteDetailComponent }  from './site-detail/site-detail.component';
import { RequireAuthenticationGuard }  from './require-authentication.guard'
import { RequireAdminGuard }  from './require-admin.guard'

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
  {
    path: 'admin/user',
    component: UserAdminComponent,
    canActivate: [ RequireAuthenticationGuard, RequireAdminGuard ],
  },
  { path: 'login', component: LoginComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
