import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { ActivatedRoute, Router, NavigationEnd } from '@angular/router';

import { Site } from '../site';
import { SiteService } from '../site.service';
import { IsLoadingService } from '../is-loading.service';

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
    private isLoadingService: IsLoadingService,
    private router: Router) {

      this.router.events.subscribe(event => {
        if (event instanceof NavigationEnd) {
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
    this.isLoadingService.add();
    this.siteService.getSiteByDomain(domain)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
      });
  }

  getSite(id: number): void {
    this.isLoadingService.add();
    this.siteService.getSite(id)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
      });
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    this.isLoadingService.add();
    this.siteService.updateSite(this.site)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
        this.siteUpdated.emit(this.site);
      });
  }

}
