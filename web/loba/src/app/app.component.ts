import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd, NavigationStart, NavigationCancel, NavigationError } from '@angular/router';
import { Observable } from 'rxjs';
import { filter } from 'rxjs/operators';

import { Site } from './site';
import { IsLoadingService } from './is-loading.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit{
  title = 'loba';
  refresh = false;
  isLoading: Observable<boolean>;

  constructor(
    private isLoadingService: IsLoadingService,
    private router: Router) { }

  ngOnInit(): void {
    this.isLoading = this.isLoadingService.isLoading$();

    this.router.events
      .pipe(
        filter(
          event =>
            event instanceof NavigationStart ||
            event instanceof NavigationEnd ||
            event instanceof NavigationCancel ||
            event instanceof NavigationError,
        ),
      )
      .subscribe(event => {
        // If it's the start of navigation, `add()` a loading indicator
        if (event instanceof NavigationStart) {
          this.isLoadingService.add();
          return;
        }

        // Else navigation has ended, so `remove()` a loading indicator
        this.isLoadingService.remove();
      });
  }

  onActivate(componentReference: any) {
    //Below will subscribe to the siteUpdated emitter
    componentReference.siteUpdated.subscribe((site: Site) => {
      this.refresh = (this.refresh == false);
      this.router.navigateByUrl(`/site/${site.domain}`);
    });

    componentReference.siteRemoved.subscribe((site: Site) => {
      this.refresh = (this.refresh == false);
      this.router.navigateByUrl(``);
    });
  }
}
