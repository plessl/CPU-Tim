const unsigned int beef = 0xDEADBEEF;
const unsigned int cafe = 0xCAFEBABE;

volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;



int main(){

    unsigned int d = fb_base[0];

    d = d | beef;
    d = d ^ cafe;

    fb_base[1] = d;
}
