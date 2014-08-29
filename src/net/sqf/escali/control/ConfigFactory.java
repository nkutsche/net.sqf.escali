package net.sqf.escali.control;

import javax.xml.transform.Source;

import net.sqf.stringUtils.TextSource;

public class ConfigFactory {
	public static Config createConfig(Source configIs){
		try {
			return new Config(TextSource.readXmlFile(configIs));
		} catch (Exception e) {
			return new Config();
		}
	}
	
	public static Config createDefaultConfig(){
		return new Config();
	}
	
	public static Config createConfig(String[] phase, String[] lang, boolean xmlSaveMode){
		Config conf = createDefaultConfig();
		conf.setLanguage(lang);
		conf.setPhase(phase);
		conf.setXmlSaveMode(xmlSaveMode);
		return conf;
	}
}
