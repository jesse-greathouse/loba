import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { Site } from './site';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'loba';
  refresh = false;

  constructor(
    private router: Router) { }

  onActivate(componentReference: any) {
    //Below will subscribe to the siteUpdated emitter
    componentReference.siteUpdated.subscribe((site: Site) => {
      this.refresh = (this.refresh == false);
      this.router.navigateByUrl(`/site/${site.domain}`);
    });
  }
}
