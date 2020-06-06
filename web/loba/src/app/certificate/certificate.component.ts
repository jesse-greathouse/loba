import { Component, OnInit, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { FormGroup, FormControl, Validators} from '@angular/forms';

import { Site } from '../site';
import { Certificate } from '../certificate';
import { CertificateService } from '../certificate.service';

@Component({
  selector: 'app-certificate',
  templateUrl: './certificate.component.html',
  styleUrls: ['./certificate.component.css']
})
export class CertificateComponent implements OnInit, OnChanges {

  @Input() site: Site;
  @Output() certificateUpdated: EventEmitter<Certificate> = new EventEmitter();
  @Output() certificateRemoved: EventEmitter<Certificate> = new EventEmitter();

  certificateForm = new FormGroup({
    certificate: new FormControl('', [Validators.required]),
    key: new FormControl('', [Validators.required]),
    certificateSource: new FormControl('', [Validators.required]),
    keySource: new FormControl('', [Validators.required])
  });

 constructor(
    private certificateService: CertificateService) { }

  ngOnInit(): void {
  }

  ngOnChanges(): void {
  }

  get f(){
    return this.certificateForm.controls;
  }

  onCertificateChange(event: any) {
  
    if (event.target.files.length > 0) {
      const file = event.target.files[0];
      this.certificateForm.patchValue({
        certificateSource: file
      });
    }
  }

  onKeyChange(event: any) {
  
    if (event.target.files.length > 0) {
      const file = event.target.files[0];
      this.certificateForm.patchValue({
        keySource: file
      });
    }
  }

  submit(){
    const formData = new FormData();
    const certificateFile = this.certificateForm.get('certificateSource').value;
    const keyFile = this.certificateForm.get('keySource').value;
    formData.append('upstream_id', String(this.site.upstream.id));
    formData.append('certificate', certificateFile, certificateFile.name);
    formData.append('key', keyFile, keyFile.name);

    this.save(formData);
  }

  save(formData: FormData): void {
    // If the upstream doesn't have a certificate
    // then it's new and it should be posted.
    if (this.site.upstream.certificate === null) {
      this.certificateService.addCertificate(formData)
        .subscribe(certificate => {
          this.site.upstream.certificate = certificate;
          this.certificateUpdated.emit(this.site.upstream.certificate);
        });
    } else {
      this.certificateService.updateCertificate(this.site.upstream.certificate.id, formData)
        .subscribe(certificate => {
          this.site.upstream.certificate = certificate;
          this.certificateUpdated.emit(this.site.upstream.certificate);
        });
    }
  }

  private factoryCertificate(): Certificate {
    return {
      id: 0,
      upstream_id: this.site.upstream.id,
      certificate: null,
      key: null
    }
  }

}
