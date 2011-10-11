package net.mariovieira.utils
{
	import com.soenkerohde.mobile.StageWebViewUIComponent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import net.mariovieira.interfaces.IDispose;
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	
	public class UtilsStageWebView extends StageWebViewUIComponent implements IDispose
	{
		public static const DEFAULT_SHOW_TIMER_VALUE :Number = 7000;
		public static const DEFAULT_HIDE_TIMER_VALUE :Number = 5000;
		
		//could have used one timer instance and changed their delays and observers, but nah, quick one...
		protected var _showTimer				:Timer;
		protected var _hideTimer				:Timer;
		protected var _showTimerValue			:Number = DEFAULT_SHOW_TIMER_VALUE; 
		protected var _hideTimerValue			:Number = DEFAULT_HIDE_TIMER_VALUE;
		protected var _autoShow					:Boolean;
		protected var _autoHide					:Boolean;
		
		private var _visibilityAllowed			:Boolean = true;
		private var _added						:Boolean;
		private var _wasOpen					:Boolean;
		
		public function UtilsStageWebView(){}
		
		/**
		 * 
		 * Allows to redraw the StageWebView viewPort in order to reposition it (eg: autoOrients true)
		 * 
		 */		
		public function updateViewPortMeasures():void
		{
			if(stageWebView)
				stageWebView.viewPort = new Rectangle(0, yOffset, myStage.width, myStage.fullScreenHeight - yOffset);
		}
		
		public function set visibilityAllowed(value:Boolean):void
		{
			_visibilityAllowed = value;
			if(!value)
			{
				_wasOpen = stageWebView != null; 
				hide();
				broadcastClose();
			}
			else if(_wasOpen)
			{
				show();
				broadcastOpen();
			}
		}
		
		/**
		 *
		 * It will show the StageWebView after the elapsed DEFAULT_SHOW_TIMER_VALUE, and remove it if was visible.
		 * @see DEFAULT_SHOW_TIMER_VALUE
		 *  
		 * @param value
		 * 
		 */		
		public function set autoShowTimer(value:Boolean):void
		{	
			_autoShow = value;
			setupTimer(true, value);
			startTime(_showTimer, true);
		}
		
		/**
		 *
		 * It will hide the StageWebView after the elapsed DEFAULT_HIDE_TIMER_VALUE
		 * @see DEFAULT_HIDE_TIMER_VALUE
		 *  
		 * @param value
		 * 
		 */
		public function set autoHideTimer(value:Boolean):void
		{
			_autoHide = value; 
			setupTimer(false, value);
		}
		
		/**
		 * 
		 * Set a new value for the showing the StageWebView
		 * 
		 * @param value
		 * 
		 */		
		public function set showTimerDelay(value:Number):void
		{
			_showTimerValue = value;
			if(_showTimer)
				_showTimer.delay = value;
		}
		
		/**
		 * 
		 * Set a new timer for hiding the StageWebView
		 * 
		 * @param value
		 * 
		 */		
		public function set hideTimerDelay(value:Number):void
		{
			_hideTimerValue = value;
			if(_hideTimer) 
				_hideTimer.delay = value;
		}
		
		
		override public function dispose(recursive:Boolean=true):void
		{
			super.dispose();
			setupTimer(true, false);
			setupTimer(false, false);
		}
		/************************ SETUP ************************/
		
		override protected function buildStageWebView():void
		{
			if(!_autoShow) 
			{
				super.buildStageWebView();
			}
		}
		
		private function checkNeedsBuilding():void
		{
			if(!_added) 
			{
				_added = true;
				super.buildStageWebView();
			}
		}
		
		private function startTime(timer:Timer, startNotStop:Boolean):void
		{
			if(startNotStop) 
			{
				timer.reset();
				timer.start();
			}
			else
			{
				timer.stop();
			}
		}
		
		protected function onHideTimer(event:TimerEvent):void
		{
			startTime(_hideTimer, false);
			broadcastClose();
			hide();
			
			if(_autoShow)
				startTime(_showTimer, true);
		}

		protected function onShowTimer(event:TimerEvent):void
		{
			if(_visibilityAllowed)
			{
				checkNeedsBuilding();
				
				startTime(_showTimer, false);
				broadcastOpen();
				show();
				
				if(_autoHide)
				{
					startTime(_hideTimer, true);
				}
			}
		}

		private function broadcastOpen():void
		{
			dispatchEvent(new Event(Event.OPEN));
		}

		private function broadcastClose():void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function setupTimer(showNotHideTimer:Boolean, mountNotUnmout:Boolean):void
		{
			if(showNotHideTimer)
			{
				if(mountNotUnmout)
				{
					_showTimer = new Timer(_showTimerValue);
					_showTimer.addEventListener(TimerEvent.TIMER, onShowTimer);
				}
				else
				{
					if(_showTimer)
					{
						_showTimer.removeEventListener(TimerEvent.TIMER, onHideTimer);
						_showTimer = null;
					}
				}
			}
			else
			{
				if(mountNotUnmout)
				{
					_hideTimer = new Timer(_hideTimerValue);
					_hideTimer.addEventListener(TimerEvent.TIMER, onHideTimer);
				}
				else
				{
					if(_hideTimer)
					{
						_hideTimer.removeEventListener(TimerEvent.TIMER, onHideTimer);
						_hideTimer = null;
					}
				}
			}
		}
	}
}