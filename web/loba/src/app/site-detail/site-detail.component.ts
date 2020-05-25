import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { ActivatedRoute, Router, NavigationEnd, NavigationStart } from '@angular/router';

import { Site } from '../site';
import { SiteService } from '../site.service';

@Component({
  host: {
    class:'content-wrapper',
  },
  selector: 'app-site-detail',
  templateUrl: './site-detail.component.html',
  styleUrls: ['./site-detail.component.css']
})
export class SiteDetailComponent implements OnInit {

  @Input() site: Site;
  @Output() siteUpdated: EventEmitter<Site> = new EventEmitter();

  constructor(
    private siteService: SiteService, 
    private route: ActivatedRoute,
    private router: Router) {

      this.router.events.subscribe(event => {
        if (event instanceof NavigationStart) {
          // TODO: Show loading indicator
        }

        if (event instanceof NavigationEnd) {
          // TODO: Hide loading indicator
          this.loadSiteDetail();
        }
      });
  }

  ngOnInit(): void {
  }

  loadSiteDetail(): void {
    const domain = this.route.snapshot.paramMap.get('domain');
    // If a domain is requested and it's not the same as the currently diplayed domain
    if (domain && 
        (typeof this.site === 'undefined' || domain !== this.site.domain)) {
      this.getSiteByDomain(domain);
    }
  }

  getSiteByDomain(domain: string): void {
    this.siteService.getSiteByDomain(domain)
      .subscribe(site => this.site = site);
  }

  getSite(id: number): void {
    this.siteService.getSite(id)
      .subscribe(site => this.site = site);
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    this.siteService.updateSite(this.site)
      .subscribe(site => {
        this.site = site;
        this.siteUpdated.emit(this.site);
      });
  }

}
