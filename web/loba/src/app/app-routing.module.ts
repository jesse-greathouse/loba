import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { SiteDetailComponent }  from './site-detail/site-detail.component';


const routes: Routes = [
  { path: '', component: SiteDetailComponent },
  { path: 'site/:domain', component: SiteDetailComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
