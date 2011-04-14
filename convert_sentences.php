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

while ($line = fgets(STDIN, 4096))
{
	if (!preg_match('/^(\d+)\. (.+)$/', trim($line), $parts))
		continue;
	
	$sentence = preg_replace('/\[(.+?)\]/', ' $1 ', $parts[2]);
	
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
	
	$words = array_flatten($words);
	
	$words = array_map(function($word) {
		return preg_match('/[A-Z]|[^\w\[\]]/', $word)
			? sprintf("'%s'", str_replace("'", "\'", $word))
			: $word;
	}, $words);
	
	//var_dump($sentence,$words);
	//continue;
	
	printf("sentence_(%d, [%s]).\n", $parts[1], implode(',', $words));
}