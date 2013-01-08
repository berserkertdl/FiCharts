package com.fiCharts.charts.legend
{
	import com.fiCharts.charts.chart2D.core.model.DataRender;
	import com.fiCharts.utils.XMLConfigKit.XMLVOMapper;
	import com.fiCharts.utils.XMLConfigKit.style.ContainerStyle;
	import com.fiCharts.utils.XMLConfigKit.style.LabelStyle;
	
	/**
	 * 图例的样式模型
	 */	
	public class LegendStyle extends ContainerStyle
	{
		public function LegendStyle()
		{
			super();
		}
		
		/**
		 */		
		private var _style:String;

		public function get style():String
		{
			return _style;
		}

		/**
		 */		
		public function set style(value:String):void
		{
			if (_style != value)
			{
				_style = value;
				
				var xml:Object = XMLVOMapper.getStyleXMLBy_ID(_style);
				
				if (xml)
					XMLVOMapper.fuck(xml, this);
			}
		}

		/**
		 */		
		public function get icon():DataRender
		{
			return 	_icon;
		}
		
		/**
		 */		
		public function set icon(value:DataRender):void
		{
			_icon = XMLVOMapper.updateObject(value, _icon) as DataRender;
		}
		
		/**
		 */		
		private var _icon:DataRender;
		
		/**
		 */		
		private var _label:LabelStyle;

		/**
		 */
		public function get label():LabelStyle
		{
			return _label;
		}

		/**
		 * @private
		 */
		public function set label(value:LabelStyle):void
		{
			_label = value;
		}
		
		/**
		 */		
		private var _position:String = 'bottom';

		/**
		 */
		public function get position():String
		{
			return _position;
		}

		/**
		 * @private
		 */
		public function set position(value:String):void
		{
			_position = value;
		}

		
	}
}