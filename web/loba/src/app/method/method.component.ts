import { Component, OnInit, OnChanges, Input, Output, EventEmitter } from '@angular/core';

import { Method } from '../method';
import { MethodService } from '../method.service';
import { IsLoadingService } from '../is-loading.service';

@Component({
  selector: 'app-method',
  templateUrl: './method.component.html',
  styleUrls: ['./method.component.css']
})
export class MethodComponent implements OnInit, OnChanges {

  @Input() selectedMethod: Method;
  @Output() methodSelected: EventEmitter<number> = new EventEmitter();
  selected: number;
  methods: Method[];

  constructor(
    private methodService: MethodService,
    private isLoadingService: IsLoadingService) { }

  ngOnInit(): void {
    this.getMethods();
  }

  ngOnChanges(): void {
    this.initSelected();
  }

  selectionChange(id: number): void {
    this.methodSelected.emit(id);
  }

  initSelected(): void {
    if (!this.selectedMethod.id) {
      this.selected = 1;
    } else {
      this.selected = this.selectedMethod.id;
    }
  }

  getMethods(): void {
    this.isLoadingService.add();
    this.methodService.getMethods()
      .subscribe(methods => {
        this.methods = methods;
        this.initSelected();
        this.isLoadingService.remove();
      });
  }

}
