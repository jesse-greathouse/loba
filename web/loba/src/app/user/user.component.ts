import { Component, Input, OnInit, OnChanges} from '@angular/core';

import { Role } from '../role';
import { User } from '../user';
import { IsLoadingService } from '../is-loading.service';
import { UserService } from '../user.service';

const ADMIN = "ADMIN";
const SUPER_USER = "SUPER_USER";
const USER = "USER";

@Component({
  selector: 'app-user',
  templateUrl: './user.component.html',
  styleUrls: ['./user.component.css']
})
export class UserComponent implements OnInit, OnChanges {
  @Input() user: User;
  @Input() role: Role;
  roles: Role[] = [
    {id: 1, name: ADMIN},
    {id: 2, name: SUPER_USER},
    {id: 3, name: USER},
  ]

  constructor(
    private isLoadingService: IsLoadingService,
    private userService: UserService) { }

  ngOnInit(): void {
    console.log(this.user);
  }

  ngOnChanges(): void {
  }

  removeConfirm(): void {
    
  }

  roleChange($event): void {
    this.save();
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    this.isLoadingService.add();
    this.userService.updateUser(this.user)
      .subscribe(user => {
        this.user = user;
        this.isLoadingService.remove();
      });
  }

}
