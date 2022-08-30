package kabam.rotmg.messaging.impl.incoming.talisman
{
   import com.company.assembleegameclient.util.FreeList;
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.data.TalismanData;
   import kabam.rotmg.messaging.impl.incoming.*;
   
   public class TalismanEssenceData extends IncomingMessage
   {
       
      
      public var essence_:int;
      
      public var essenceCap_:int;
      
      public var talismans_:Vector.<TalismanData>;
      
      public function TalismanEssenceData(param1:uint, param2:Function)
      {
         this.talismans_ = new Vector.<TalismanData>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.essence_ = param1.readInt();
         this.essenceCap_ = param1.readInt();
         var _loc2_:int = 0;
         var _loc3_:int = param1.readShort();
         _loc2_ = _loc3_;
         while(_loc2_ < this.talismans_.length)
         {
            FreeList.deleteObject(this.talismans_[_loc2_]);
            _loc2_++;
         }
         this.talismans_.length = Math.min(_loc3_,this.talismans_.length);
         while(this.talismans_.length < _loc3_)
         {
            this.talismans_.push(FreeList.newObject(TalismanData) as TalismanData);
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.talismans_[_loc2_].parseFromInput(param1);
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("TALISMAN_ESSENCE_DATA","talismans_");
      }
   }
}
