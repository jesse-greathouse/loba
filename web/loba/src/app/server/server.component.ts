import { Component, OnInit, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

import { Site } from '../site';
import { Server } from '../server';
import { ServerService } from '../server.service';
import { RemoveServerConfirmComponent } from '../remove-server-confirm/remove-server-confirm.component'

@Component({
  selector: 'app-server',
  templateUrl: './server.component.html',
  styleUrls: ['./server.component.css']
})
export class ServerComponent implements OnInit, OnChanges {

  @Input() site: Site;
  @Input() server: Server;
  @Input() lockHealth: boolean;
  @Input() locked_fail_timeout: number;
  @Input() locked_max_fails: number;
  @Output() serverRemoved: EventEmitter<Server> = new EventEmitter();

  constructor(
    public dialog: MatDialog,
    private serverService: ServerService) { }

  ngOnInit(): void {
  }

  ngOnChanges(): void {
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    // If the server doesn't have an id
    // then it's new and it should be posted.
    if (!this.server.id) {
      this.serverService.addServer(this.server)
        .subscribe(server => {
          this.server = server;
        });
    } else {
      this.serverService.updateServer(this.server)
        .subscribe(server => {
          this.server = server;
        });
    }
  }

  removeConfirm(): void {
    const dialogRef = this.dialog.open(RemoveServerConfirmComponent, {
      width: '400px',
      data: { server: this.server }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.serverRemoved.emit(this.server);
      }
    });
  }

}
