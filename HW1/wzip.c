#include <stdio.h>
#include <stdlib.h>
int count = 0;
int first_file = 1;
int ch = 0;
unsigned char curr_word = 0;
unsigned char prev_word = 0;
void filewrite(void){
fwrite(&count, sizeof(int), 1, stdout);
fwrite(&prev_word, sizeof(char), 1, stdout);
}
void compress(FILE *fp){
if(first_file){
ch = fgetc(fp);
if(ch == EOF) return;
prev_word = (unsigned char) ch;
count = 1;
first_file = 0;
}
while ((ch = fgetc(fp)) != EOF) {
curr_word = (unsigned char) ch;
if(curr_word == prev_word){
count++;
} else{
filewrite();
prev_word = curr_word;
count = 1;
}
}
}
int main(int argc, char *argv[]) {
if (argc < 2) {
printf(stderr, "wzip: file1 [file2 ...]\n");
return 1;
}
for (int i = 1; i < argc; i++) {
FILE *fp = fopen(argv[i], "r");
if (fp == NULL) {
printf(stderr, "wzip: cannot open file\n");
return 1;
}
compress(fp);
fclose(fp);
}
if (count > 0){
filewrite();
}
return 0;

