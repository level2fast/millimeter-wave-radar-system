.PHONY: all clean

job_name=project_specification

all:
	pdflatex -jobname=${job_name} -halt-on-error -output-format=pdf -- tex/doc.tex

clean:
	rm -f -- ${job_name}.{aux,log,pdf,toc,glg,glo,gls,ist,out} tex/*.aux
