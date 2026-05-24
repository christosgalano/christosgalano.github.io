---
title: "bioETH-PRS"
excerpt: "My first research paper, combining Fully Homomorphic Encryption with programmable blockchain to compute Polygenic Risk Scores on encrypted genomic data, without ever exposing the plaintext."
tagline: "Confidential Polygenic Risk Scoring on the blockchain"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/research/bioeth-prs/bioeth-prs.webp
tags:
  - research
  - cryptography
---

## A first paper

Earlier this month, my first research paper went live on arXiv:

> **bioETH-PRS: Confidential Polygenic Risk Scoring without a Trusted Evaluator via Fully Homomorphic Encryption on a Programmable Blockchain**

This was also my first collaboration with the University of Texas, working alongside Kimonas Provatas and Ilias Georgakopoulos-Soares. The experience was meaningful on multiple levels, and I'm grateful for the work we did together.

I won't attempt a full academic walkthrough here. Instead, I want to share what the paper is about, what made it interesting to work on, and what I took away from the process.

## The problem

Polygenic Risk Scores (PRSs) are a powerful tool in genomics. They aggregate thousands of genetic effect estimates, typically derived from Genome-Wide Association Studies (GWAS), into a single number that predicts an individual's susceptibility to a particular disease.

The computation itself is straightforward: a dot product between a person's genotype vector and a vector of GWAS-derived weights. But the data involved is about as sensitive as it gets. Your DNA.

In most existing approaches, computing a PRS requires exposing raw genotype data to third-party infrastructure. Some solutions use homomorphic encryption to protect the data during computation, but they still rely on a **trusted evaluator**, a designated party that performs the computation and is assumed not to collude or leak information.

The question we asked was: *can we remove that trust assumption entirely?*

## The approach

bioETH-PRS replaces the trusted evaluator with immutable smart contracts on a blockchain that natively supports Fully Homomorphic Encryption (fhEVM). The core idea:

- The genotype vector is encrypted client-side and submitted as FHE ciphertexts
- The GWAS weights can be published publicly or stored encrypted
- The dot product is computed entirely in the encrypted domain; validators execute the arithmetic without ever seeing plaintext
- The result is released through a noisy oracle that emits only a categorical risk level (Low / Medium / High), never the raw score

No party (not the validators, not the contract deployer, not the model publisher) ever observes the raw genomic data or the exact score.

## The architecture

We designed a four-contract system, each handling a distinct concern:

| Contract | Role |
|----------|------|
| **GenomicRegistry** | Stores references to encrypted SNP data with per-address access control |
| **ModelMarketplace** | Lists GWAS weight vectors, public or private |
| **PRSComputeEngine** | Executes the chunked FHE dot product |
| **ResultOracle** | Adds on-chain noise and emits a categorical classification |

This separation ensures that data custody, model publication, computation, and output release are all isolated, both logically and in terms of access control.

We also introduced two computation paths: a **classic chunked path** (upload all SNPs, then compute) and a **streaming path** that interleaves upload and computation per chunk. The streaming path reduced gas by roughly 37% in our mock measurements.

## Quantization

One of the more interesting technical challenges was representing signed floating-point GWAS weights as unsigned 64-bit integers, the only numeric type available in the TFHE scheme we used.

We developed a three-step fixed-point quantization scheme:

1. Scale the floating-point weights to an integer range
2. Shift to eliminate negative values
3. Encode as `uint64`

The scheme achieves machine-epsilon reconstruction accuracy on validated fixtures, and we built an on-chain-compatible decoding path so the final score can be interpreted correctly after decryption.

## What I learned

Working on this was different from anything I'd done before. My background is in software engineering: building systems, writing infrastructure code, shipping products. Research has a different rhythm.

A few things stood out:

- **Precision of language matters differently.** In engineering, clarity serves maintainability. In a paper, every sentence carries weight because reviewers will challenge it. Hedging correctly ("may be cost-competitive" vs. "is cost-competitive") is a skill.
- **The gap between prototype and claim is vast.** We had working contracts, gas profiles, and fixture-validated quantization. But turning that into defensible claims about a system's properties required a level of rigor I hadn't exercised in the same way before.
- **Interdisciplinary work is humbling.** Genomics, cryptography, blockchain, privacy. No one person masters all of these. The collaboration forced me to learn deeply in areas outside my comfort zone.

## Looking forward

The paper suggests that confidential PRS computation on-chain is feasible today, particularly in low-gas deployment environments. There's more to explore: formal differential privacy guarantees, multi-party GWAS weight contribution, scaling to larger SNP panels. I'm looking forward to continuing in this space.

If you're interested, the paper is available on [arXiv](https://arxiv.org/abs/2605.21634).

## Resources

- [**Paper (arXiv)**](https://arxiv.org/abs/2605.21634)
- [**Paper (PDF)**](/assets/files/bioETH-PRS.pdf)
- [**Zama fhEVM**](https://github.com/zama-ai/fhevm)
