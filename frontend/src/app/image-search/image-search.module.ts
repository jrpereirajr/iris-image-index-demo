import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import {MatExpansionModule} from '@angular/material/expansion';

import { MarkdownModule } from 'ngx-markdown';

import { ImageSearchRoutingModule } from './image-search-routing.module';
import { ImageSearchComponent } from './image-search.component';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';


@NgModule({
  declarations: [
    ImageSearchComponent
  ],
  imports: [
    CommonModule,
    MatCardModule,
    MatExpansionModule,
    MatProgressSpinnerModule,
    MarkdownModule.forRoot(),
    ImageSearchRoutingModule
  ]
})
export class ImageSearchModule { }
