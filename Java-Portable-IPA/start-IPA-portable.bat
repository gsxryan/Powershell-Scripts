:: Portable Java Launcher script (current directory)
:: Template for recreating IPA launch script
:: jars launched from CWD/public
:: string and other details can be grabbed from the standard desktop launcher
%~dp0jre1.8.0_111\bin\java.exe -Xms40m -Xmx750m "-Djava.net.preferIPv4Stack=true" "-Djavaws.webstart.shortcut.title=IPA" "-Djavaws.com.ingenuity.app.abbreviation=IPA" "-Djavaws.com.ingenuity.aboutbox.header=about_header.jpg" "-Djavaws.com.ingenuity.visualization.enable_hierarchical_pathways=false" "-Djavaws.com.ingenuity.quickstart.image=quick_start_no_blue_links.gif" "-Djavaws.com.ingenuity.ipacommon.answers_url=https://answers.ingenuity.com/answers" "-Djavaws.com.ingenuity.reportview.reportsurl.domain=https://reports.ingenuity.com" "-Djavaws.com.ingenuity.reportview.reportsurl.contextroot=rs" "-Djavaws.com.ingenuity.ipacommon.isa_url=https://apps.ingenuity.com/isa" "-Djavaws.com.ingenuity.car_url=http://uedev5.ingenuity.com:8164/anaweb/car/anawebController" "-Djava.util.Arrays.useLegacyMergeSort=true" "-Djavaws.com.ingenuity.ipa.networkfading.enable=true" "-Djavaws.com.ingenuity.ipa.effectoverlay.enable=false" "-Djavaws.com.ingenuity.ipa.mechanisticnetwork.enable=false" "-Djavaws.com.ingenuity.ipacommon.ingsso_url=https://apps.ingenuity.com/ingsso/" "-Djavaws.com.ingenuity.ipa.regeffect.maxPathwaysToMerge=1000000000" "-Djavaws.com.ingenuity.ipa.regeffect.maxDuration=120" "-Djavaws.com.ingenuity.ipa.dataset.maxMeasurementsPerObservation=8" "-Djavaws.com.ingenuity.ipa.phospho.enable=false" "-Djavaws.com.ingenuity.ipa.pathway.limit.nodes=1000" -classpath "%~dp0public\appThird1.jar;%~dp0public\appThird2.jar;%~dp0public\commonThird.jar;%~dp0public\ipa.jar" com.ingenuity.ipa.explorer.ui.IpaApplication "-d" "-j" "ipipaapp6.ingenuity.com_<LAUNCHSTRINGOMITTED>.ipipaapp6" -s https://analysis.ingenuity.com/pa/