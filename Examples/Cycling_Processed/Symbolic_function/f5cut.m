function [R5cut,p5cut] = f5cut(in1,in2,in3)
%F5CUT
%    [R5CUT,P5CUT] = F5CUT(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    25-Jan-2021 14:43:37

R4cut1_1 = in3(28);
R4cut1_2 = in3(31);
R4cut1_3 = in3(34);
R4cut2_1 = in3(29);
R4cut2_2 = in3(32);
R4cut2_3 = in3(35);
R4cut3_1 = in3(30);
R4cut3_2 = in3(33);
R4cut3_3 = in3(36);
p4cut1 = in2(10);
p4cut2 = in2(11);
p4cut3 = in2(12);
q7 = in1(7,:);
q11 = in1(11,:);
q12 = in1(12,:);
q13 = in1(13,:);
q36 = in1(36,:);
q37 = in1(37,:);
t2 = cos(q7);
t3 = cos(q11);
t4 = cos(q12);
t5 = cos(q13);
t6 = cos(q36);
t7 = cos(q37);
t8 = sin(q7);
t9 = sin(q11);
t10 = sin(q12);
t11 = sin(q13);
t12 = sin(q36);
t13 = sin(q37);
t14 = R4cut1_1.*t2;
t15 = R4cut1_3.*t2;
t16 = R4cut1_2.*t3;
t17 = R4cut2_1.*t2;
t18 = R4cut2_3.*t2;
t19 = R4cut2_2.*t3;
t20 = R4cut3_1.*t2;
t21 = R4cut3_3.*t2;
t22 = R4cut3_2.*t3;
t23 = R4cut1_1.*t8;
t24 = R4cut1_3.*t8;
t25 = R4cut1_2.*t9;
t26 = R4cut2_1.*t8;
t27 = R4cut2_3.*t8;
t28 = R4cut2_2.*t9;
t29 = R4cut3_1.*t8;
t30 = R4cut3_3.*t8;
t31 = R4cut3_2.*t9;
t32 = -t24;
t33 = -t27;
t34 = -t30;
t35 = t15+t23;
t36 = t18+t26;
t37 = t21+t29;
t38 = t14+t32;
t39 = t17+t33;
t40 = t20+t34;
t41 = t4.*t35;
t42 = t4.*t36;
t43 = t4.*t37;
t44 = t10.*t35;
t45 = t10.*t36;
t46 = t10.*t37;
t47 = t3.*t38;
t48 = t3.*t39;
t49 = t3.*t40;
t50 = t9.*t38;
t51 = t9.*t39;
t52 = t9.*t40;
t53 = -t50;
t54 = -t51;
t55 = -t52;
t56 = t25+t47;
t57 = t28+t48;
t58 = t31+t49;
t59 = t16+t53;
t60 = t19+t54;
t61 = t22+t55;
t62 = t5.*t56;
t63 = t5.*t57;
t64 = t5.*t58;
t65 = t11.*t56;
t66 = t11.*t57;
t67 = t11.*t58;
t68 = t4.*t59;
t69 = -t62;
t70 = t4.*t60;
t71 = -t63;
t72 = t4.*t61;
t73 = -t64;
t74 = t10.*t59;
t75 = t10.*t60;
t76 = t10.*t61;
t77 = -t74;
t78 = -t75;
t79 = -t76;
t80 = t44+t68;
t81 = t45+t70;
t82 = t46+t72;
t83 = t41+t77;
t84 = t42+t78;
t85 = t43+t79;
t86 = t5.*t83;
t87 = t5.*t84;
t88 = t5.*t85;
t89 = t11.*t83;
t90 = t11.*t84;
t91 = t11.*t85;
t92 = t65+t86;
t93 = t66+t87;
t94 = t67+t88;
t95 = t69+t89;
t96 = t71+t90;
t97 = t73+t91;
t101 = -t12.*(t62-t89);
t102 = -t12.*(t63-t90);
t103 = -t12.*(t64-t91);
t104 = t12.*(t62-t89);
t105 = t12.*(t63-t90);
t106 = t12.*(t64-t91);
t98 = t6.*t92;
t99 = t6.*t93;
t100 = t6.*t94;
t107 = t98+t104;
t108 = t99+t105;
t109 = t100+t106;
R5cut = reshape([-t12.*t92+t6.*(t62-t89),-t12.*t93+t6.*(t63-t90),-t12.*t94+t6.*(t64-t91),t7.*t80+t13.*t107,t7.*t81+t13.*t108,t7.*t82+t13.*t109,-t13.*t80+t7.*t107,-t13.*t81+t7.*t108,-t13.*t82+t7.*t109],[3,3]);
if nargout > 1
    p5cut = [R4cut1_2.*2.622748756236262e-1+p4cut1+t14.*3.746783937480375e-2-t15.*1.988677628354968e-2-t23.*1.988677628354968e-2-t24.*3.746783937480375e-2-t44.*1.354606500454285e-2-t62.*4.015783809857385e-2-t65.*1.654349215448425e-1-t68.*1.354606500454285e-2-t86.*1.654349215448425e-1+t89.*4.015783809857385e-2;R4cut2_2.*2.622748756236262e-1+p4cut2+t17.*3.746783937480375e-2-t18.*1.988677628354968e-2-t26.*1.988677628354968e-2-t27.*3.746783937480375e-2-t45.*1.354606500454285e-2-t63.*4.015783809857385e-2-t66.*1.654349215448425e-1-t70.*1.354606500454285e-2-t87.*1.654349215448425e-1+t90.*4.015783809857385e-2;R4cut3_2.*2.622748756236262e-1+p4cut3+t20.*3.746783937480375e-2-t21.*1.988677628354968e-2-t29.*1.988677628354968e-2-t30.*3.746783937480375e-2-t46.*1.354606500454285e-2-t64.*4.015783809857385e-2-t67.*1.654349215448425e-1-t72.*1.354606500454285e-2-t88.*1.654349215448425e-1+t91.*4.015783809857385e-2];
end
