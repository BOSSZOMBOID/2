package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class UnboxResultPacket extends IncomingMessage
   {
       
      
      public var items_:Vector.<int>;
      
      public function UnboxResultPacket(_arg_1:uint, _arg_2:Function)
      {
         this.items_ = new Vector.<int>();
         super(_arg_1,_arg_2);
      }
      
      override public function parseFromInput(_arg1:IDataInput) : void
      {
         var _local1:int = 0;
         this.items_.length = 0;
         var _local2:int = _arg1.readShort();
         this.items_.length = _local2;
         for(_local1 = 0; _local1 < _local2; )
         {
            this.items_[_local1] = _arg1.readInt();
            _local1++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("UNBOXRESULT","items_");
      }
   }
}
