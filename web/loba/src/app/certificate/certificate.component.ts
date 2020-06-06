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

  onCertificateClick() {
    const fileUpload = document.getElementById('certificate') as HTMLInputElement;
    fileUpload.click();
  }

  onKeyClick() {
    const fileUpload = document.getElementById('key') as HTMLInputElement;
    fileUpload.click();
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
    let canSubmit: boolean = false;
    formData.append('upstream_id', String(this.site.upstream.id));

    const keyFile = this.certificateForm.get('keySource').value;
    if (typeof keyFile == 'object') {
      formData.append('key', keyFile, keyFile.name);
      canSubmit = true;
    }

    const certificateFile = this.certificateForm.get('certificateSource').value;
    if (typeof certificateFile == 'object') {
      formData.append('certificate', certificateFile, certificateFile.name);
      canSubmit = true
    }

    if (canSubmit) {
      this.save(formData);
    }
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
}
