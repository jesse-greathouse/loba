import { Component, OnInit, OnChanges, Input, Output, EventEmitter, ViewChild} from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { FormGroup, FormControl, Validators} from '@angular/forms';

import { MatButton } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';

import { Site } from '../site';
import { Certificate } from '../certificate';
import { Upstream } from '../upstream';
import { CertificateService } from '../certificate.service';
import { UpstreamService } from '../upstream.service';
import { RemoveCertificateConfirmComponent } from '../remove-certificate-confirm/remove-certificate-confirm.component'
import { RemoveKeyConfirmComponent } from '../remove-key-confirm/remove-key-confirm.component'
import { SelfSignedConfirmComponent } from '../self-signed-confirm/self-signed-confirm.component'

@Component({
  selector: 'app-certificate',
  templateUrl: './certificate.component.html',
  styleUrls: ['./certificate.component.css']
})
export class CertificateComponent implements OnInit, OnChanges {

  @Input() site: Site;
  @Output() certificateUpdated: EventEmitter<Certificate> = new EventEmitter();
  @Output() certificateRemoved: EventEmitter<Certificate> = new EventEmitter();
  @ViewChild("certificateRemoveButton") certificateRemoveButton: MatButton;
  @ViewChild("certificateUploadButton") certificateUploadButton: MatButton;
  @ViewChild("certificateDownloadButton") certificateDownloadButton: MatButton;
  @ViewChild("keyRemoveButton") keyRemoveButton: MatButton;
  @ViewChild("keyUploadButton") keyUploadButton: MatButton;
  @ViewChild("keyDownloadButton") keyDownloadButton: MatButton;
  showCertIcon: boolean = false;
  showKeyIcon: boolean = false;

  certificateForm = new FormGroup({
    certificate: new FormControl('', [Validators.required]),
    key: new FormControl('', [Validators.required]),
    certificateSource: new FormControl('', [Validators.required]),
    keySource: new FormControl('', [Validators.required])
  });

 constructor(
    public dialog: MatDialog,
    private upstreamService: UpstreamService,
    private certificateService: CertificateService) { }

  ngOnInit(): void {
    setTimeout(() => {
      this.getCertificate();
    }, 0);
  }

  ngOnChanges(): void {
    setTimeout(() => {
      this.getCertificate();
    }, 0);
  }

  get f() {
    return this.certificateForm.controls;
  }

  get hasCertificate(): boolean {
    if (  this.site.upstream.certificate === undefined
          || this.site.upstream.certificate === null ) return false;
    return (this.site.upstream.certificate.certificate === null) ? false : true;
  }

  get hasKey(): boolean {
    if (  this.site.upstream.certificate === undefined
          || this.site.upstream.certificate === null ) return false;
    return (this.site.upstream.certificate.key === null) ? false : true;
  }

  getCertificate(): void {
    if (this.site.upstream.id > 0) {
    this.certificateService.getCertificateByUpstream(this.site.upstream)
      .subscribe((certificate: Certificate) => {
        if (certificate === undefined ) certificate = null;
        this.site.upstream.certificate = certificate;
        this.updateButtonStatus();
      });
    } else {
      this.site.upstream.certificate = null;
      this.updateButtonStatus();
    }
  }

  updateButtonStatus(): void {
    if (this.hasCertificate) {
      this.certificateRemoveButton.disabled = false;
      this.certificateDownloadButton.disabled = false;
      this.showCertIcon = true;
    } else {
      this.certificateRemoveButton.disabled = true;
      this.certificateDownloadButton.disabled = true;
      this.showCertIcon = false;
    }

    if (this.hasKey) {
      this.keyRemoveButton.disabled = false;
      this.keyDownloadButton.disabled = false;
      this.showKeyIcon = true;
    } else {
      this.keyRemoveButton.disabled = true;
      this.keyDownloadButton.disabled = true;
      this.showKeyIcon = false;
    }
  }

  onCertificateClick(): void {
    const fileUpload = document.getElementById('certificate') as HTMLInputElement;
    fileUpload.click();
  }

  onCertificateDownload(): void {
    if (this.hasCertificate) {
      this.downloadFile(this.site.upstream.certificate.certificate);
    }
  }

  removeCertificateConfirm(): void {
    const dialogRef = this.dialog.open(RemoveCertificateConfirmComponent, {
      width: '400px',
      data: { certificate: this.site.upstream.certificate }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.certificateRemoved.emit(this.site.upstream.certificate);
        this.getCertificate();
      }
    });
  }

  onKeyClick(): void {
    const fileUpload = document.getElementById('key') as HTMLInputElement;
    fileUpload.click();
  }

  onKeyDownload(): void {
    if (this.hasKey) {
      this.downloadFile(this.site.upstream.certificate.key);
    }
  }

  removeKeyConfirm(): void {
    const dialogRef = this.dialog.open(RemoveKeyConfirmComponent, {
      width: '400px',
      data: { certificate: this.site.upstream.certificate }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.certificateRemoved.emit(this.site.upstream.certificate);
        this.getCertificate();
      }
    });
  }

  selfSignedConfirm(): void {
    const dialogRef = this.dialog.open(SelfSignedConfirmComponent, {
      width: '600px',
      data: { domain: this.site.domain }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.certificateForm.reset();
        this.certificateUpdated.emit(this.site.upstream.certificate);
        this.getCertificate();
      }
    });
  }

  onCertificateChange(event: any): void {
    if (event.target.files.length > 0) {
      const file = event.target.files[0];
      this.certificateForm.patchValue({
        certificateSource: file
      });
      this.submit();
    }
  }

  onKeyChange(event: any): void {
    if (event.target.files.length > 0) {
      const file = event.target.files[0];
      this.certificateForm.patchValue({
        keySource: file
      });
      this.submit();
    }
  }

  submit(): void {
    const formData: FormData = new FormData();
    let canSubmit: boolean = false;
    formData.append('upstream_id', String(this.site.upstream.id));

    const keyFile = this.certificateForm.get('keySource').value;
    if (keyFile instanceof File) {
      formData.append('key', keyFile, keyFile.name);
      canSubmit = true;
    }

    const certificateFile = this.certificateForm.get('certificateSource').value;
    if (certificateFile instanceof File) {
      formData.append('certificate', certificateFile, certificateFile.name);
      canSubmit = true
    }

    if (canSubmit) {
      this.save(formData);
    }
  }

  save(formData: FormData): void {
    // If the upstream id has a value of zero, the upstream hasn't been saved yet.
    // First persist the upstream and then try to save the certificate
    if (this.site.upstream.id == 0) {
      this.addNewUpstream()
        .subscribe((upstream) => {
          formData.set('upstream_id', `${upstream.id}`);
          this.save(formData);
        });
    } else {
      // If the upstream doesn't have a certificate
      // then it's new and it should be posted.
      if (this.site.upstream.certificate === null) {
        this.certificateService.addCertificate(formData)
          .subscribe(certificate => {
            this.site.upstream.certificate = certificate;
            this.certificateForm.reset();
            this.updateButtonStatus();
            this.certificateUpdated.emit(this.site.upstream.certificate);
          });
      } else {
        this.certificateService.updateCertificate(this.site.upstream.certificate.id, formData)
          .subscribe(certificate => {
            this.site.upstream.certificate = certificate;
            this.certificateForm.reset();
            this.updateButtonStatus();
            this.certificateUpdated.emit(this.site.upstream.certificate);
          });
      }
    }
  }

  addNewUpstream(): Observable<Upstream> {
    return this.upstreamService.addUpstream(this.site.upstream).pipe(
      map(upstream => {
        this.site.upstream = upstream;
        return upstream;
      })
    );
  }

  private downloadFile(url: string): void {
    var a = document.createElement('A') as HTMLAnchorElement;
    a.href = url;
    a.download = url.substr(url.lastIndexOf('/') + 1);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }
}
