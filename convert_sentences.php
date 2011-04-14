#!/usr/bin/php
<?php

error_reporting(E_ALL ^ E_STRICT);
ini_set('display_errors', true);

function array_flatten($input)
{
	$output = array();
	
	foreach ($input as $element)
	{
		if (is_array($element))
			$output = array_merge($output, array_flatten($element));
		else
			$output[] = $element;
	}
	
	return $output;
}

while (($line = fgets(STDIN, 4096)) !== false)
{
	// remove ending \n
	$line = trim($line);
	
	// Comment any non-sentence line (like instructions) and pass-thru whitespace.
	if (!preg_match('/^(\d+)\. (.+)$/', $line, $parts))
	{
		if (empty($line))
			print "\n";
		else
			printf("%% %s\n", $line);
		continue;
	}
	
	// Remove the bracktes which indicate where van Gompel measured.
	$sentence = preg_replace('/\[(.+?)\]/', ' $1 ', $parts[2]);
	
	// Turn the {a,b,c} option clauses into lists with lists of words [[a],[b],[c]].
	$sentence = preg_replace_callback('/\{(.+?)\}/', function($match) {
		$options = explode(',', $match[1]);
		$options = array_map(function($option) { return sprintf('[%s]', trim($option)); }, $options);
		return sprintf('[%s]', implode(' ', $options));
	}, $sentence);
	
	//preg_match_all('/(^|\s)([\w\[\]]+|[^\w])($|\s)/', $sentence, $words);
	$words = explode(' ', trim($sentence));
	
	// filter out empty 'words'
	$words = array_filter($words, function($word) {
		return !empty($word); 
	});
	
	// split words and punctuation
	$words = array_map(function($word) {
		return preg_match('/^(\w+)([^\w])$/', $word, $match)
			? array($match[1], $match[2])
			: $word;
	}, $words);
	
	// now flatten out all the bumps the 'split words' filter made.
	$words = array_flatten($words);
	
	// quote all the non-prolog-atom words
	$words = array_map(function($word) {
		return preg_match('/[A-Z]|[^\w\[\]]/', $word)
			? sprintf("'%s'", str_replace("'", "\'", $word))
			: $word;
	}, $words);
	
	$sentence = implode(',', $words);
	
	// Horrible hack to fix a quoting error:
	$sentence = preg_replace("/'(\[+)/", "$1'", $sentence);
	
	$sentence = str_replace(",]", "]", $sentence);
	
	printf("variable_sentence(%d, [%s]).\n", $parts[1], $sentence);
}