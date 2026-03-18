#!/usr/bin/env bash 

[false, true].each do |rsupb| 
  [207_000, 250_000, 300_000, 325_000, 350_000, 400_000, 450_000, 500_000].each do |aa| 
    taxr = 1 - (2.7272727272727E-7 * aa + 0.31454545454545); 
    if rsupb; 
      rsup = (1 - (207000.0 / aa)).round(3) 
    else
      rsup = 0 
    end
    mine= (aa * taxr) - (6100 *12) - (aa * taxr * rsup * 0.22) ; 
    xer=(6100*12) + (aa * taxr * rsup * 0.22) + (0.71 * 60000); 
    puts "inc - #{aa.round(2)} - rsu% - #{rsup.round(2)} \tincome #{mine.round(0)} \t- xer #{xer.round(0)} - taxr #{(1 - taxr).round(3)} \ttot: #{(mine + xer).round(0)} \ttest: #{((mine + xer - (0.71 * 60_000) ) / (taxr)).round(0) == aa}" 
  end
end

