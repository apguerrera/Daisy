// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// 2019 OKIMS

pragma solidity ^0.5.0;

library Pairing {

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero. 
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    /*
     * @return The sum of two points of G1
     */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {

        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas, 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success,"pairing-add-failed");
    }

    /*
     * @return The product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {

        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas, 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {

        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];

        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < 4; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas, 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success,"pairing-opcode-failed");

        return out[0] != 0;
    }
}

contract BatchUpdateStateTreeVerifier {

    using Pairing for *;

    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[21] IC;
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(13803770480400599308561397041480832538699258257644499651816827828995022230329), uint256(2227802632457882736587392704226847142881760818540675138244369037489405437869));
        vk.beta2 = Pairing.G2Point([uint256(5343703751272196867441566007481828550359074652131424851996296678913617454556), uint256(20680499076754622696159873514772428026735951404154530274924728810242283886209)], [uint256(1602795704630843441947311743306077173311887920853261334700701517412895205778), uint256(20144128979256488152137243229420643354039327882217121620646110400677086831064)]);
        vk.gamma2 = Pairing.G2Point([uint256(18874592077762754731902169693967750956117716603915559922571592393494072792265), uint256(5026387249074657171304057537849132979504311811595990831291006945664420606473)], [uint256(2316347086601330754122456630915446835768545210622930791037022872250264043900), uint256(20780622660242356343557991118335977154808816309268176299914642518343982713655)]);
        vk.delta2 = Pairing.G2Point([uint256(18645497397755877227076717309486942877990807077709505702208789714661881330544), uint256(20368802916943528640902975381576278292226642112903164403620018467440354775190)], [uint256(18112994255122885001160701622526630609097657934101347532779406663126340712293), uint256(393211548176112951267772066046650097062125626372360425005936476418336299317)]);
        vk.IC[0] = Pairing.G1Point(uint256(931187513458558839152786217161922558800041814137211843366919011339624683624), uint256(12882961370197961301972109887817646999443528815637916070925059607458809334210));
        vk.IC[1] = Pairing.G1Point(uint256(1613370576283623253930114817732844171982227556877417899663881623742360074495), uint256(9878010433600767789469303328890076403832255529618395633360359061636112528101));
        vk.IC[2] = Pairing.G1Point(uint256(10977194566930513371764288200596608631313891775922573867435289496421409843027), uint256(18214512324604499182777126864599346760974080214450601218660157924132008298370));
        vk.IC[3] = Pairing.G1Point(uint256(19007771531334589809802973612916535144938853348927976305164107652283972894481), uint256(3664919909933283951106604283271341593074665076901117018408768757059214015272));
        vk.IC[4] = Pairing.G1Point(uint256(6479414462505161512300452726686436076284905589406926710426753245781506094922), uint256(6130106179638015474309971366773312753799858156600590260441923878082437108583));
        vk.IC[5] = Pairing.G1Point(uint256(11200029404496619288495846314204555057056689813645895707626129649810194706321), uint256(1156858275905723521159297694094334187707196986449519679170357556736073461592));
        vk.IC[6] = Pairing.G1Point(uint256(650716452247091057884938289014946748984425881071232727541197017319372272216), uint256(12984693242712726100195608363280623092918308365049989482480910918385393144279));
        vk.IC[7] = Pairing.G1Point(uint256(19468597462004721194333245631196299593924257516305687436622013635886237193440), uint256(1797287101164626272684505932994609473596742567778604851632183582122486589544));
        vk.IC[8] = Pairing.G1Point(uint256(14919831548401919027196283588857551881096156238097926385155092214610558585715), uint256(1483711854578009861675937935359447171334500522670307178043268048978495248207));
        vk.IC[9] = Pairing.G1Point(uint256(21048845279943003325853402882283101204764600538425421964827336557362737292349), uint256(6273455489627998172911365700802575713771762021624588780605930104677211860191));
        vk.IC[10] = Pairing.G1Point(uint256(4629458132078179062358355260311097889349797212043244650887181099304067964685), uint256(19066381683931830376455982594233819207299623101401543145099178190331967938018));
        vk.IC[11] = Pairing.G1Point(uint256(3535594769552831683903315877435478563818724550867612992108477057840230276292), uint256(21047040413618108083909473608780607241858514366829155864632435394764524050698));
        vk.IC[12] = Pairing.G1Point(uint256(3735035151863078989159612982208945402947778235435943510181374578144185324548), uint256(3483233430123917563490422980638788099270510020011071305912325460743242497942));
        vk.IC[13] = Pairing.G1Point(uint256(5472962545146005174410161745864548403079202705627009319728495361276109549333), uint256(18090948390222390754599660977885685205473071308678205662548510319894924179171));
        vk.IC[14] = Pairing.G1Point(uint256(17785155027634626680544823403694247569902909492998635103350704875900320318498), uint256(4835479732663708426767249802847686235396905796078204549668533709277571081264));
        vk.IC[15] = Pairing.G1Point(uint256(10343078719147344833776779175857070791367015479606331995794090131028032866835), uint256(13819257145178380469442552147358815571664507436786120481641648540025023811698));
        vk.IC[16] = Pairing.G1Point(uint256(15452679221323975646339843038739805011228276127915748354709297196666109942423), uint256(15570930645635264787268468781297119255902068380708790532146117245593713449206));
        vk.IC[17] = Pairing.G1Point(uint256(9953926841180829861138751274940950730518147451384376027082554677141582422705), uint256(16536849117335768361572382633496249674704378043118383594074175836592852377312));
        vk.IC[18] = Pairing.G1Point(uint256(14536481642281267260796766231042838687374215941875062984097927687409012062006), uint256(15606610825673691735539459429948335394148753602286875319849411084466313298793));
        vk.IC[19] = Pairing.G1Point(uint256(6244338575328176878668929190545669171971419301629218187335545970491328385540), uint256(9821927857112182949860428576170090818103638791947381428374890284168567315926));
        vk.IC[20] = Pairing.G1Point(uint256(4866607652478731726825408411969739699550526918051505442171526194889478044488), uint256(12452746722436987905212831223356324258888802242551173389606338786354581274749));

    }
    
    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[20] memory input
    ) public view returns (bool) {

        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        VerifyingKey memory vk = verifyingKey();

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.A.X < PRIME_Q, "verifier-aX-gte-prime-q");
        require(proof.A.Y < PRIME_Q, "verifier-aY-gte-prime-q");

        require(proof.B.X[0] < PRIME_Q, "verifier-bX0-gte-prime-q");
        require(proof.B.Y[0] < PRIME_Q, "verifier-bY0-gte-prime-q");

        require(proof.B.X[1] < PRIME_Q, "verifier-bX1-gte-prime-q");
        require(proof.B.Y[1] < PRIME_Q, "verifier-bY1-gte-prime-q");

        require(proof.C.X < PRIME_Q, "verifier-cX-gte-prime-q");
        require(proof.C.Y < PRIME_Q, "verifier-cY-gte-prime-q");

        // Make sure that every input is less than the snark scalar field
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.plus(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        vk_x = Pairing.plus(vk_x, vk.IC[0]);

        return Pairing.pairing(
            Pairing.negate(proof.A),
            proof.B,
            vk.alfa1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.C,
            vk.delta2
        );
    }
}
