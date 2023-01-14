pragma circom 2.0.0;

template MiMC5Feistel() {
    signal input iL;
    signal input iR;
    signal input k;

    signal output oL;
    signal output oR;

    var nRounds = 20;
    var c[20] = [
        0,
        25823191961023811529686723375255045606187170120624741056268890390838310270028,
        71153255768872006974285801937521995907343848376936063113800887806988124358800,
        51253176922899201987938365653129780755804051536550826601168630951148399005246,
        66651710483985382365580181188706173532487386392003341306307921015066514594406,
        45887003413921204775397977044284378920236104620216194900669591190628189327887,
        14399999722617037892747232478295923748665564430258345135947757381904956977453,
        29376176727758177809204424209125257629638239807319618360680345079470240949145,
        13768859312518298840937540532277016512087005174650120937309279832230513110846,
        54749662990362840569021981534456448557155682756506853240029023635346061661615,
        25161436470718351277017231215227846535148280460947816286575563945185127975034,
        90370030464179443930112165274275271350651484239155016554738639197417116558730,
        92014788260850167582827910417652439562305280453223492851660096740204889381255,
        40376490640073034398204558905403523738912091909516510156577526370637723469243,
        903792244391531377123276432892896247924738784402045372115602887103675299839,
        112203415202699791888928570309186854585561656615192232544262649073999791317171,
        114801681136748880679062548782792743842998635558909635247841799223004802934045,
        111440818948676816539978930514468038603327388809824089593328295503672011604028,
        64965960071752809090438003157362764845283225351402746675238539375404528707397,
        98428510787134995495896453413714864789970336245473413374424598985988309743097
    ];

    signal lastOutputL[nRounds + 1];
    signal lastOutputR[nRounds + 1];

    var base[nRounds];
    signal base2[nRounds];
    signal base4[nRounds];

    lastOutputL[0] <== iL;
    lastOutputR[0] <== iR;

    for(var i = 0; i < nRounds; i++){
        base[i] = lastOutputR[i] + k + c[i];
        base2[i] <== base[i] * base[i];
        base4[i] <== base2[i] * base2[i];

        lastOutputR[i + 1] <== lastOutputL[i] + base4[i] * base[i];
        lastOutputL[i + 1] <== lastOutputR[i];
    }

    oL <== lastOutputL[nRounds];
    oR <== lastOutputR[nRounds];
}
template MiMC5Sponge(nInputs) {
    signal input k;
    signal input ins[nInputs];
    signal output o;

    signal lastR[nInputs + 1];
    signal lastC[nInputs + 1];

    lastR[0] <== 0;
    lastC[0] <== 0;

    component layers[nInputs];

    for(var i = 0; i < nInputs; i++){
        layers[i] = MiMC5Feistel();

        layers[i].iL <== lastR[i] + ins[i];
        layers[i].iR <== lastC[i];
        layers[i].k <== k;

        lastR[i + 1] <== layers[i].oL;
        lastC[i + 1] <== layers[i].oR;
    }

    o <== lastR[nInputs];
}
component main = MiMC5Sponge(2);