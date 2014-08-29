package net.sqf.escali;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.cmdGui.Validation;
import net.sqf.escali.control.Config;
import net.sqf.escali.control.ConfigFactory;
import net.sqf.escali.control.SVRLReport;
import net.sqf.escali.resources.EscaliOptions;
import net.sqf.stringUtils.TextSource;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.xml.sax.SAXException;

public class EscaliCmd {

	private CommandLine cmd;
	private TextSource result;

	private EscaliCmd(CommandLine cmd) {
		this.cmd = cmd;

	}

	public static void main(String[] args) {
		DefaultParser parser = new DefaultParser();
		Options options = EscaliOptions.getOptions();
		CommandLine cmd;
		try {
			cmd = parser.parse(options, args);
			EscaliCmd escmd = new EscaliCmd(cmd);
			escmd.process();
		} catch (ParseException e) {
			System.err.println(e.getLocalizedMessage());
			HelpFormatter hf = new HelpFormatter();
			hf.printHelp("java -jar escali.jar [options]\nOptions:", options);
		} catch (XPathExpressionException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (TransformerException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (URISyntaxException e) {
			e.printStackTrace();
		} catch (XMLStreamException e) {
			e.printStackTrace();
		}
	}

	private void process() throws XPathExpressionException, IOException, TransformerException, SAXException, URISyntaxException, XMLStreamException {
		if (EscaliOptions.hasOption(cmd, EscaliOptions.VALIDATE_OPTION)) {
			validateProcess();
		}
	}
	
	private void validateProcess() throws IOException, XPathExpressionException, TransformerException, SAXException, URISyntaxException, XMLStreamException{
		String[] vValues = EscaliOptions.getOptionValues(cmd, EscaliOptions.VALIDATE_OPTION);
		File schema = new File(vValues[1]);
		File instance = new File(vValues[0]); 
		Config config = ConfigFactory.createDefaultConfig();
		if(EscaliOptions.hasOption(cmd, EscaliOptions.PHASE_OPTION)){
			config.setPhase(EscaliOptions.getOptionValue(cmd, EscaliOptions.PHASE_OPTION));
		}
		Validation cmdValidation = new Validation(schema, config);
		
		
		
		SVRLReport report = cmdValidation.validate(instance);
		this.result = report.getSVRL();
		if(EscaliOptions.hasOption(cmd, EscaliOptions.OUTPUT_TYPE_OPTION)){
			String type = EscaliOptions.getOptionValue(cmd, EscaliOptions.OUTPUT_TYPE_OPTION);
			this.result = report.getFormatetReport(type);
		}
		
		finishProcess();
	}
	
	private void finishProcess() throws IOException{
		if(this.result == null){
			return;
		} else if (EscaliOptions.hasOption(cmd, EscaliOptions.OUTPUT_OPTION)){
			File outputfile = new File(EscaliOptions.getOptionValue(cmd, EscaliOptions.OUTPUT_OPTION));
			TextSource.write(outputfile, this.result);
		} else {
			System.out.println(this.result.toString());
		}
	}
}
