public without sharing class Operators {

	public static final String EQ = 'Equals (Checkbox)';
	public static final String NEQ = 'Does Not Equal (Checkbox)';
	public static final String LT = 'Less Than';
	public static final String LTE = 'Less Than or Equals';
	public static final String GT = 'Greater Than';
	public static final String GTE = 'Greater Than or Equals';
	public static final String CNTN = 'Contains';
	public static final String NOT_CNTN = 'Does Not Contain';
	public static final String IN_IN = 'Equals (Text)';
	public static final String IN_NOTIN = 'Not Equals (Text)';
	
	private static Map<String,Logical> OPERATOR_INDEX = new Map<String,Logical> {
		EQ => new Equals(),NEQ => new NotEquals(),LT => new LessThan(),
		LTE => new LessThanEquals(), GT => new GreaterThan(),
		GTE => new GreaterThanEquals(), CNTN => new Contains(),
		NOT_CNTN => new NotContains(), IN_IN => new ININ(), 
		IN_NOTIN => new NotIn() 
	};	
	
	public static Logical getInstance(String key) {
		return OPERATOR_INDEX.get(key);
	}
	
	public interface Logical {
		Boolean evaluate(Object leftValue, Object rightValue);
		String getSymbol();
	}

	public class ININ implements Logical {
		private Map<String,Value> testValueCache = new Map<String,Value>();
		
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) && (testValue == null)) {
				return true;
			}
			if ( ((fieldValue == null) && (testValue != null)) || ((fieldValue != null) && (testValue == null)) ) {
				return false;
			}
			System.debug('first one----'+fieldValue);
		 if (fieldValue instanceof String) {
 				
 				if(((String)fieldValue).length()==18 && ((String)testValue).length()==15)
 				{
 					return(((String)fieldValue).contains(((String)testValue)));
 				}
 				
				String fv = ((String)fieldValue).toLowerCase();
				String tv = String.valueOf(testValue).toLowerCase();
				if (!testValueCache.containsKey(tv)) {
					Value v = Operators.valueFor(tv);
					testValueCache.put(tv, v);
				}
				return testValueCache.get(tv).equals(fv);
			} 
			
			else if (fieldValue instanceof Boolean) {
				return ( ((Boolean)fieldValue) == String.valueOf(testValue).toLowerCase().equals('true'));
			} else if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) == toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) == toDateSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) == toDateTimeSkipNullCheck(testValue));
			}
			else
			{
				System.debug('Last one----'+fieldValue);
			}
			
			return false;
		}
		
		public String getSymbol() {
			return 'IN';
		}
	}
	
	public class NotIn implements Logical {
		private ININ i = new ININ();
		public Boolean evaluate(Object fieldValue, Object testValue) {
			return !i.evaluate(fieldValue, testValue);
		}
		
		public String getSymbol() {
			return 'NOT IN';
		}
	}
	
	public class Equals implements Logical {
		private Map<String,Value> testValueCache = new Map<String,Value>();
		
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) && (testValue == null)) {
				return true;
			}
			if ( ((fieldValue == null) && (testValue != null)) || ((fieldValue != null) && (testValue == null)) ) {
				return false;
			}
			System.debug('firstt one----'+fieldValue);
		 if (fieldValue instanceof String) {
 				
 				if(((String)fieldValue).length()==18 && ((String)testValue).length()==15)
 				{
 					return(((String)fieldValue).contains(((String)testValue)));
 				}
 				
				String fv = ((String)fieldValue).toLowerCase();
				String tv = String.valueOf(testValue).toLowerCase();
				if (!testValueCache.containsKey(tv)) {
					Value v = Operators.valueFor(tv);
					testValueCache.put(tv, v);
				}
				return testValueCache.get(tv).equals(fv);
			} 
			
			else if (fieldValue instanceof Boolean) {
				return ( ((Boolean)fieldValue) == String.valueOf(testValue).toLowerCase().equals('true'));
			} else if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) == toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) == toDateSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) == toDateTimeSkipNullCheck(testValue));
			}
			else
			{
				System.debug('Last one----'+fieldValue);
			}
			
			return false;
		}
		
		public String getSymbol() {
			return '=';
		}
	}
	
	public class NotEquals implements Logical {
		private Equals equals = new Equals();
		public Boolean evaluate(Object fieldValue, Object testValue) {
			return !equals.evaluate(fieldValue, testValue);
		}
		
		public String getSymbol() {
			return '!=';
		}
	}
	
	public class Contains implements Logical {
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) || (testValue == null)) {
				return false;
			}
			if ( ((fieldValue == null) && (testValue != null)) || ((fieldValue != null) && (testValue == null)) ) {
				return false;
			}
			if(((String)fieldValue).length()==18 && ((String)testValue).length()==15)
 				{
 					return(((String)fieldValue).contains(((String)testValue)));
 				}
			String fv = ((String)fieldValue).toLowerCase();
			String tv = String.valueOf(testValue).toLowerCase();
			if (fv.indexOf(';') != -1) {
				for (String s : fv.split(';')) {
					if (tv.contains(s)) return true;
				}
				return false;
			}
			return (tv.contains(fv));
			
		}
		
		public String getSymbol() {
			return 'includes';
		}
	}
	
	public class NotContains implements Logical {
		Contains contains = new Contains();
		public Boolean evaluate(Object fieldValue, Object testValue) {
			return (! contains.evaluate(fieldValue, testValue));
		}
		
		public String getSymbol() {
			return 'excludes';
		}
	}
	
	public class GreaterThan implements Logical {
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) || (testValue == null)) {
				return false;
			}
			if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) > toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) > toDateSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) > toDateTimeSkipNullCheck(testValue));
			}
			return false;
		}
		
		public String getSymbol() {
			return '>';
		}
	}
	
	public class GreaterThanEquals implements Logical {
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) || (testValue == null)) {
				return false;
			}
			if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) >= toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) >= toDateSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) >= toDateTimeSkipNullCheck(testValue));
			}
			return false;
		}
		
		public String getSymbol() {
			return '>=';
		}
	}
	
	public class LessThan implements Logical {
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) || (testValue == null)) {
				return false;
			}
			if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) < toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) < toDateTimeSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) < toDateSkipNullCheck(testValue));
			}
			return false;
		}
		
		public String getSymbol() {
			return '<';
		}
	}
	
	public class LessThanEquals implements Logical {
		public Boolean evaluate(Object fieldValue, Object testValue) {
			if ((fieldValue == null) || (testValue == null)) {
				return false;
			}
			if (fieldValue instanceof Decimal) {
				return ( ((Decimal)fieldValue) <= toDecimalSkipNullCheck(testValue));
			} else if (fieldValue instanceof Date) {
				return ( ((Date)fieldValue) <= toDateSkipNullCheck(testValue));
			} else if (fieldValue instanceof DateTime) {
				return ( ((DateTime)fieldValue) <= toDateTimeSkipNullCheck(testValue));
			}
			return false;
		}
		
		public String getSymbol() {
			return '<=';
		}
	}
	
	private virtual class Value {
		private String value;
		
		private Value() {
		}
		
		private Value(String value) {
			this.value = value;
			if (value.startsWith('"') && value.endsWith('"') && value.length() > 1) {
				this.value = value.substring(1, value.length()-1);
			}
		}
		
		public virtual boolean equals(String value) {
			return this.value.equals(value);
		}
	}
	
	private class MultipleValue extends Value {
		private Set<String> values;
		
		private MultipleValue(String value) {
			values = new Set<String>();
			for (String v : value.split(',')) {
				values.add(v.trim());
			}
		}
		
		public override boolean equals(String value) {
			return values.contains(value);
		}
	}
	
	/** This method is not used in the class
	private static Decimal toDecimal(Object value) {
		if (value == null) {
			return null;
		}
		return toDecimalSkipNullCheck(value);
	}*/
	
	private static Decimal toDecimalSkipNullCheck(Object value) {
		Decimal result = null;
		try {
			result =  Decimal.valueOf(String.valueOf(value));
		} catch (TypeException te) {
		}
		return result;
	}
	
	/**This method is not used in the class
	private static Date toDate(Object value) {
		if (value == null) {
			return null;
		}
		return toDateSkipNullCheck(value);
	}*/
	
	private static Date toDateSkipNullCheck(Object value) {
		Date result = null;
		try {
			result =  Date.valueOf(String.valueOf(value));
		} catch (TypeException te) {
		}
		return result;
	}
	
	/**This method is not used in the class
	private static DateTime toDateTime(Object value) {
		if (value == null) {
			return null;
		}
		return toDateTimeSkipNullCheck(value);
	}*/
	
	private static DateTime toDateTimeSkipNullCheck(Object value) {
		DateTime result = null;
		try {
			result =  DateTime.valueOf(String.valueOf(value));
		} catch (TypeException te) {
		}
		return result;
	}
	
	private static Value valueFor(String value) {
		value = value.toLowerCase();
		if ( (value.indexOf(',') > -1) && (!value.startsWith('"')) && (!value.endsWith('"')) ) {
			return new MultipleValue(value);
		} else {
			return new Value(value);
		}
	}
/*	
	testMethod static void testDateTime() {
		Operators op = Operators.LessThan;
		DateTime dt1 = Datet
		op.evaluate(, Object testValue) {
	}*/
}