package kabam.rotmg.messaging.impl.incoming
{
   import com.company.assembleegameclient.util.FreeList;
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.data.GroundTileData;
   import kabam.rotmg.messaging.impl.data.ObjectData;
   
   public class Update extends IncomingMessage
   {
       
      
      public var tiles:Vector.<GroundTileData>;
      
      public var newObjs:Vector.<ObjectData>;
      
      public var drops:Vector.<int>;
      
      public function Update(param1:uint, param2:Function)
      {
         this.tiles = new Vector.<GroundTileData>();
         this.newObjs = new Vector.<ObjectData>();
         this.drops = new Vector.<int>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = param1.readShort();
         _loc2_ = _loc3_;
         while(_loc2_ < this.tiles.length)
         {
            FreeList.deleteObject(this.tiles[_loc2_]);
            _loc2_++;
         }
         this.tiles.length = Math.min(_loc3_,this.tiles.length);
         while(this.tiles.length < _loc3_)
         {
            this.tiles.push(FreeList.newObject(GroundTileData) as GroundTileData);
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.tiles[_loc2_].parseFromInput(param1);
            _loc2_++;
         }
         this.newObjs.length = 0;
         _loc3_ = param1.readShort();
         _loc2_ = _loc3_;
         while(_loc2_ < this.newObjs.length)
         {
            FreeList.deleteObject(this.newObjs[_loc2_]);
            _loc2_++;
         }
         this.newObjs.length = Math.min(_loc3_,this.newObjs.length);
         while(this.newObjs.length < _loc3_)
         {
            this.newObjs.push(FreeList.newObject(ObjectData) as ObjectData);
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.newObjs[_loc2_].parseFromInput(param1);
            _loc2_++;
         }
         this.drops.length = 0;
         var _loc4_:int = param1.readShort();
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            this.drops.push(param1.readInt());
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("UPDATE","tiles_","newObjs_","drops_");
      }
   }
}
