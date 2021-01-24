import { Component, OnInit } from '@angular/core';
import { ImageService } from './image.service';

@Component({
  selector: 'app-image-search',
  templateUrl: './image-search.component.html',
  styleUrls: ['./image-search.component.scss']
})
export class ImageSearchComponent implements OnInit {

  images = [];
  colorSimilars = [];
  sql = `\`\`\`
  SELECT * FROM
  \`\`\``;
  selectedCardIndex = -1;
  loading = false;

  constructor(private imageService: ImageService) { }

  ngOnInit(): void {
    const id = setTimeout(() => {
      this.loading = true;
    }, 1000);
    this.imageService.getImages('test').subscribe((images: string[]) => {
      clearTimeout(id);
      this.loading = false;
      this.images = images;
    });
  }

  search(image: string) {
    const id = setTimeout(() => {
      this.loading = true;
    }, 1000);
    this.imageService.getColorSimilars(image).subscribe(similars => {
      clearTimeout(id);
      this.loading = false;
      this.colorSimilars = similars.similarImages;
      this.sql = `
      \`\`\`sql
      ${similars.sql
          .replace('FROM', '\nFROM')
          .replace('WHERE', '\nWHERE\n\t\t\t')}
      \`\`\``;
    });
  }

  onSelectCard(index: number) {
    this.selectedCardIndex = index;
  }

  isCardSelected(index: number) {
    return index === this.selectedCardIndex;
  }

}
