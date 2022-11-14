
//  import 'package:icicles_animation_dart/icicles_animation_dart.dart';

// class Icicles {
//   List<Color> _pixels;
//   List<Color> get pixels{
//     return List.unmodifiable(_pixels);
//   }

//    int get xCount{
//     return this.animation.header.xCount;
//   }
//   public get yCount(): number {
//     return this.animation.header.yCount;
//   }

//   constructor(public readonly animation: Animation) {
//     this._pixels = new Array(animation.header.ledsCount).fill(new Color());
//   }

//   private _isValidIndex(index: number): void {
//     if (index >= this._pixels.length || index < 0) {
//       throw new Error(
//         `Invalid pixel index provided: "${index}". Valid range is from "0" to "${
//           this._pixels.length - 1
//         }"`
//       );
//     }
//   }

//   public getPixelIndex = (x: number, y: number): number => {
//     const index = x * this.yCount + y;
//     this._isValidIndex(index);
//     return index;
//   };

//   public getPixelColor = (x: number, y: number): Color => {
//     const index = this.getPixelIndex(x, y);
//     return this._pixels[index];
//   };

//   public getPixelColorAtIndex = (index: number): Color => {
//     this._isValidIndex(index);

//     return this._pixels[index];
//   };

//   public setPixelColor = (x: number, y: number, color: Color): void => {
//     const index = this.getPixelIndex(x, y);
//     this._pixels[index] = color;
//   };

//   public setColumnColor = (x: number, color: Color): void => {
//     const index = this.getPixelIndex(x, 0);
//     for (let i = index; i < index + this.yCount; i++) {
//       this._pixels[i] = color;
//     }
//   };

//   public setRowColor = (y: number, color: Color): void => {
//     for (let x = 0; x < this.xCount; x++) {
//       const index = this.getPixelIndex(x, y);
//       this._pixels[index] = color;
//     }
//   };

//   public setPixelColorAtIndex = (index: number, color: Color) => {
//     this._isValidIndex(index);

//     this._pixels[index] = color;
//   };

//   public setAllPixelsColor = (color: Color) => {
//     for (let i = 0; i < this.pixels.length; i++) {
//       this._pixels[i] = color;
//     }
//   };

//   public setPixels = (pixels: Array<Color>): void => {
//     if (this._pixels.length !== pixels.length) {
//       throw new Error(
//         `Unsupported pixels length: "${pixels.length}". Size of "${this.pixels.length}" is allowed.`
//       );
//     }
//     for (let i = 0; i < this.pixels.length; i++) {
//       this._pixels[i] = pixels[i];
//     }
//   };

//   public toFrame = (duration: Duration): VisualFrame => {
//     const copiedPixels = this.pixels.slice(0);
//     return new VisualFrame(copiedPixels, duration.milliseconds);
//   };

//   /**
//    * When setting `duration` to any value other than 0ms, the panel color will be displayed
//    * immediately and the next frame will be delayed by the specified time.
//    *
//    * Skipping the `duration` will cause the radio panel colors to be displayed
//    * together with the `show` method invocation.
//    */
//   public setRadioPanelColor(
//     panelIndex: number,
//     color: Color,
//     duration: Duration = new Duration({ milliseconds: 0 })
//   ): void {
//     this.animation.addFrame(
//       new RadioColorFrame(panelIndex, color, duration.milliseconds)
//     );
//   }

//   public show(duration: Duration): void {
//     this.animation.addFrame(this.toFrame(duration));
//   }
// }