package kabam.rotmg.messaging.impl
{
   import com.company.ui.SimpleText;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.utils.getTimer;
   
   public class JitterWatcher extends Sprite
   {
       
      
      private var text_:SimpleText = null;
      
      private var lastRecord_:int = -1;
      
      private var ticks_:Vector.<int>;
      
      private var sum_:int;
      
      public function JitterWatcher()
      {
         this.ticks_ = new Vector.<int>();
         super();
         this.text_ = new SimpleText(14,16777215,false,0,0);
         this.text_.filters = [new DropShadowFilter(0,0,0)];
         this.addChild(this.text_);
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function get getNetJitter() : int
      {
         return int(this.jitter());
      }
      
      public function record() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = getTimer();
         if(this.lastRecord_ == -1)
         {
            this.lastRecord_ = _loc2_;
            return;
         }
         var _loc3_:int = _loc2_ - this.lastRecord_;
         this.ticks_.push(_loc3_);
         this.sum_ += _loc3_;
         if(this.ticks_.length > 50)
         {
            _loc1_ = this.ticks_.shift();
            this.sum_ -= _loc1_;
         }
         this.lastRecord_ = _loc2_;
      }
      
      private function jitter() : Number
      {
         var _loc1_:int = 0;
         var _loc2_:int = this.ticks_.length;
         if(_loc2_ == 0)
         {
            return 0;
         }
         var _loc3_:Number = this.sum_ / _loc2_;
         var _loc4_:Number = 0;
         for each(_loc1_ in this.ticks_)
         {
            _loc4_ += (_loc1_ - _loc3_) * (_loc1_ - _loc3_);
         }
         return int(Math.sqrt(_loc4_ / _loc2_) * 10) / 10;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this.stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.text_.text = "net jitter: " + int(this.jitter());
         this.text_.useTextDimensions();
      }
   }
}
