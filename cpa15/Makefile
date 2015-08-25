targets = isi.pdf
images =

all: $(targets)

pdflatex = pdflatex -interaction=errorstopmode -halt-on-error

%.pdf: %.tex biblio.bib cpa2015.cls cpalistings.sty $(images)
	$(pdflatex) $<
	bibtex $*
	$(pdflatex) $<
	$(pdflatex) $<

clean:
	rm -f $(targets) $(images) *.aux *.log *.nav *.out *.snm *.toc *.vrb *.bbl *.blg
