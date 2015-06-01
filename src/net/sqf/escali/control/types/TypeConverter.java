package net.sqf.escali.control.types;

import java.util.HashMap;

import org.joda.time.DateTime;

import net.sf.saxon.type.ValidationException;
import net.sf.saxon.value.*;

public class TypeConverter {
	private String type;
	private Class objectClass = String.class;
	public TypeConverter(String type) {
		this.type = type;
		
	}
	@SuppressWarnings("unchecked")
	public Object convertValue(String value){
		Object result;
		if(value == null){
			result = null;
		} else if (type.equals("xs:dateTime")) {
			result = getClass(type).cast(getDate(value));
		} else if (type.equals("xs:time")) {
			result = getClass(type).cast(getTime(value));
		} else if (type.equals("xs:date")) {
			result = getClass(type).cast(getDate(value));
		} else if (type.equals("xs:integer")) {
			int valInt = value.equals("") ? 0 : Integer.valueOf(value);
			result = getClass(type).cast(valInt);
		} else {
			result = getClass(type).cast(value);
		}
		return result;
	}
	
	private Class getClass(String type){
		if(typeVerifierMap.containsKey(type)){
			return typeVerifierMap.get(type);
		} else {
			return String.class;
		}
	}
	
	private static Object getTime(String value){
		return TimeValue.makeTimeValue(value);
	}
	
	private static DateValue getDate(String value){
		try {
			return new DateValue(value);
		} catch (ValidationException e) {
			return null;
		}
	}

	private static HashMap<String, Class> typeVerifierMap = new HashMap<String, Class>();
	static {
		typeVerifierMap.put(null, String.class);
		typeVerifierMap.put("xs:string", String.class);
		typeVerifierMap.put("xs:int", Integer.class);
		typeVerifierMap.put("xs:integer", Integer.class);
		typeVerifierMap.put("xs:short", Double.class);
		typeVerifierMap.put("xs:long", Double.class);
		typeVerifierMap.put("xs:decimal", Double.class);
		typeVerifierMap.put("xs:unsignedInt", Double.class);
		typeVerifierMap.put("xs:unsignedShort", Double.class);
		typeVerifierMap.put("sqf:color", String.class);
		typeVerifierMap.put("xs:date", DateValue.class);
	}
	public String convertToString(Object value) {
			if (value instanceof DateValue) {
				DateValue dv = (DateValue) value; 
				return dv.getPrimitiveStringValue().toString(); 
			}
		return value.toString();
	}
}
